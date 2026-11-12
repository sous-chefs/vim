# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'tempfile'

module Vim
  module SourceInstallation
    def installation_current?(prefix, manifest_path, fingerprint)
      prefix = validated_prefix(prefix)
      manifest_path = validate_manifest_trust!(manifest_path)
      manifest = installation_manifest(prefix, manifest_path)
      current = manifest.fetch('current', [])
      manifest['fingerprint'] == fingerprint && !current.empty? && current.all? do |relative|
        installed_entry_matches?(prefix, relative, manifest.fetch('files').fetch(relative))
      end
    rescue JSON::ParserError, Errno::ENOENT, ArgumentError
      false
    end

    def install_staged(stage, prefix, manifest_path, fingerprint)
      prefix = validated_prefix(prefix)
      manifest_path = validate_manifest_trust!(manifest_path)
      previous = installation_manifest(prefix, manifest_path)
      previous.fetch('files').each do |relative, entry|
        target = installation_target(prefix, relative)
        next unless ::File.exist?(target) || ::File.symlink?(target)
        next if installed_entry_matches?(prefix, relative, entry)

        raise "Refusing to overwrite modified managed file #{target}"
      end

      files = previous.fetch('files').dup
      directories = previous.fetch('directories').dup
      current = []
      raise 'The staged installation does not contain bin/vim' unless ::File.file?(::File.join(stage, 'bin', 'vim'))

      staged_paths = Dir.glob(::File.join(stage, '**', '*'), ::File::FNM_DOTMATCH).reject { |path| %w(. ..).include?(::File.basename(path)) }
      raise 'The staged Vim installation is empty' if staged_paths.empty?

      ensure_installation_directory(prefix, prefix, directories, ::File.stat(stage).mode & 0o777)
      staged_paths.sort_by { |path| [path.count('/'), path] }.each do |path|
        relative = path.delete_prefix("#{stage}/")
        target = installation_target(prefix, relative)
        raise "Refusing to follow a symlink parent for #{target}" unless installation_parents_safe?(prefix, relative)

        if ::File.directory?(path) && !::File.symlink?(path)
          ensure_installation_directory(target, prefix, directories, ::File.stat(path).mode & 0o777)
        else
          raise "Refusing to replace an existing directory #{target}" if ::File.directory?(target) && !::File.symlink?(target)

          entry = staged_entry(path)
          FileUtils.copy_entry(path, target, true, false, true)
          files[relative] = entry
          current << relative
        end
      end

      manifest = { 'prefix' => prefix, 'fingerprint' => fingerprint, 'files' => files, 'current' => current, 'directories' => directories.uniq }
      Tempfile.create(['vim-manifest-', '.json'], ::File.dirname(manifest_path)) do |file|
        file.write(JSON.generate(manifest))
        file.flush
        file.close
        ::File.rename(file.path, manifest_path)
      end
    end

    def remove_installation(prefix, manifest_path)
      return [] unless ::File.exist?(manifest_path)

      prefix = validated_prefix(prefix)
      manifest_path = validate_manifest_trust!(manifest_path)
      manifest = installation_manifest(prefix, manifest_path)
      retained = []
      manifest.fetch('files').each do |relative, entry|
        target = installation_target(prefix, relative)
        next unless ::File.exist?(target) || ::File.symlink?(target)

        if installed_entry_matches?(prefix, relative, entry)
          ::File.unlink(target)
        else
          retained << relative
        end
      end
      manifest.fetch('directories').sort_by { |relative| relative == '.' ? 0 : -relative.split('/').length }.each do |relative|
        target = relative == '.' ? prefix : installation_target(prefix, relative)
        next if ::File.symlink?(target) || !::File.directory?(target)
        next unless relative == '.' || installation_parents_safe?(prefix, relative)

        begin
          ::Dir.rmdir(target)
        rescue Errno::ENOTEMPTY
          # Keep unrelated or locally modified content and its parent directory.
        end
      end
      ::File.unlink(manifest_path)
      retained
    end

    private

    def validated_prefix(prefix)
      expanded = ::File.expand_path(prefix)
      raise ArgumentError, 'The filesystem root cannot be a Vim installation prefix' if expanded == '/'
      raise ArgumentError, 'The Vim installation prefix cannot be a symlink' if ::File.symlink?(expanded)

      # Bind receipts to the canonical location, including ancestors above the prefix.
      ::File.join(::File.realpath(::File.dirname(expanded)), ::File.basename(expanded))
    end

    def installation_target(prefix, relative)
      if relative.start_with?('/') || relative.split('/').any? { |part| %w(. ..).include?(part) }
        raise ArgumentError, 'Manifest path is outside the installation prefix'
      end
      target = ::File.expand_path(relative, prefix)
      raise ArgumentError, 'Manifest path is outside the installation prefix' unless target.start_with?("#{prefix}/")

      target
    end

    def installation_manifest(prefix, manifest_path)
      prefix = validated_prefix(prefix)
      manifest_path = validate_manifest_trust!(manifest_path)
      return { 'files' => {}, 'directories' => [] } unless ::File.exist?(manifest_path)

      manifest = JSON.parse(::File.read(manifest_path))
      raise ArgumentError, 'The manifest belongs to another prefix' unless manifest.fetch('prefix') == prefix

      manifest.fetch('files').each_key { |relative| installation_target(prefix, relative) }
      manifest.fetch('directories').each { |relative| installation_target(prefix, relative) unless relative == '.' }
      manifest
    end

    def validate_manifest_trust!(manifest_path)
      directory = ::File.dirname(::File.expand_path(manifest_path))
      if ::File.symlink?(directory) || !::File.directory?(directory)
        raise ArgumentError, 'Untrusted Vim state directory'
      end

      canonical_directory = ::File.realpath(directory)
      state = ::File.stat(canonical_directory)
      unless state.uid == Process.euid && (state.mode & 0o022).zero?
        raise ArgumentError, 'Untrusted Vim state directory ownership or permissions'
      end

      ancestor = canonical_directory
      loop do
        stat = ::File.stat(ancestor)
        trusted_owner = [0, Process.euid].include?(stat.uid)
        sticky = (stat.mode & 0o1000) != 0
        unless trusted_owner && ((stat.mode & 0o022).zero? || sticky)
          raise ArgumentError, 'Untrusted Vim state ancestor ownership or permissions'
        end
        break if ancestor == '/'

        ancestor = ::File.dirname(ancestor)
      end

      manifest_path = ::File.join(canonical_directory, ::File.basename(manifest_path))
      return manifest_path unless ::File.exist?(manifest_path) || ::File.symlink?(manifest_path)

      receipt = ::File.lstat(manifest_path)
      unless receipt.file? && receipt.uid == Process.euid && (receipt.mode & 0o022).zero?
        raise ArgumentError, 'Untrusted Vim state receipt type, ownership or permissions'
      end
      manifest_path
    end

    def installation_parents_safe?(prefix, relative)
      return false if ::File.symlink?(prefix)

      parts = ::File.dirname(relative).split('/')
      parts.pop if parts == ['.']
      parts.each_index.none? { |index| ::File.symlink?(::File.join(prefix, *parts.take(index + 1))) }
    end

    def installed_entry_matches?(prefix, relative, entry)
      return false unless installation_parents_safe?(prefix, relative)

      target = installation_target(prefix, relative)
      if entry.fetch('type') == 'symlink'
        ::File.symlink?(target) && ::File.readlink(target) == entry.fetch('target')
      else
        !::File.symlink?(target) && ::File.file?(target) && Digest::SHA256.file(target).hexdigest == entry.fetch('sha256')
      end
    end

    def staged_entry(path)
      if ::File.symlink?(path)
        { 'type' => 'symlink', 'target' => ::File.readlink(path) }
      elsif ::File.file?(path)
        { 'type' => 'file', 'sha256' => Digest::SHA256.file(path).hexdigest }
      else
        raise "Unsupported staged file type #{path}"
      end
    end

    def ensure_installation_directory(path, prefix, directories, mode)
      return if ::File.directory?(path) && !::File.symlink?(path)
      raise "Refusing to replace an existing path #{path}" if ::File.exist?(path) || ::File.symlink?(path)

      ::Dir.mkdir(path)
      ::File.chmod(mode, path)
      directories << (path == prefix ? '.' : path.delete_prefix("#{prefix}/"))
    end
  end
end
