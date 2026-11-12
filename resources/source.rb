# frozen_string_literal: true

require 'digest'
require 'json'
require 'shellwords'

provides :vim_source
unified_mode true

property :version, String, default: '9.2.1332'
property :source, String, default: lazy { "https://github.com/vim/vim/archive/refs/tags/v#{version}.tar.gz" }
property :checksum, [String, nil],
         default: lazy { version == '9.2.1332' ? '3cd253ad44a42be755579174e4554e20bc7863abf82fb2de5a6914f3e8a2f617' : nil }
property :prefix, String, default: '/usr/local', coerce: proc { |value| ::File.expand_path(value) },
                          callbacks: { 'must not be the filesystem root' => proc { |value| value != '/' } }
property :state_dir, String, default: '/var/lib/vim-cookbook',
                             description: 'Persistent installation manifests; keep this directory across convergences.',
                             coerce: proc { |value| ::File.expand_path(value) },
                             callbacks: { 'must not be the filesystem root' => proc { |value| value != '/' } }
property :configuration, [String, Array],
         default: %w(--without-x --enable-python3interp --enable-rubyinterp --enable-tclinterp --enable-luainterp --enable-perlinterp --enable-cscope --with-features=huge),
         coerce: proc { |value| value.is_a?(String) ? Shellwords.split(value) : value }
property :jobs, Integer, default: 2, callbacks: { 'must be positive' => proc(&:positive?) }
property :dependencies, Array, default: lazy {
  case node['platform_family']
  when 'debian'
    %w(build-essential universal-ctags libncurses-dev libperl-dev lua5.4 liblua5.4-dev python3-dev ruby-dev tcl-dev libacl1-dev libgpm-dev gettext)
  when 'suse'
    %w(gcc make ctags ncurses-devel perl python3-devel ruby-devel tcl-devel lua54 lua54-devel gettext-tools)
  else
    %w(gcc make ctags ncurses-devel perl-devel perl-ExtUtils-Embed perl-ExtUtils-ParseXS python3-devel ruby-devel tcl-devel lua lua-devel gettext)
  end
}

action_class do
  include Vim::SourceInstallation

  def source_fingerprint
    Digest::SHA256.hexdigest(JSON.generate([new_resource.version, new_resource.source, new_resource.checksum, new_resource.prefix, new_resource.configuration, new_resource.dependencies]))
  end

  def source_manifest
    ::File.join(new_resource.state_dir, "vim-installation-#{Digest::SHA256.hexdigest(new_resource.prefix)[0, 16]}.json")
  end
end

action :install do
  provider = self
  fingerprint = source_fingerprint
  manifest = source_manifest
  prefix = new_resource.prefix
  state_dir = new_resource.state_dir
  cache = Chef::Config[:file_cache_path]
  archive = ::File.join(cache, "vim-source-#{fingerprint}.tar.gz")
  build = ::File.join(cache, "vim-build-#{fingerprint}")
  stage = ::File.join(build, 'stage')
  staged_prefix = ::File.join(stage, new_resource.prefix.delete_prefix('/'))

  package new_resource.dependencies

  directory state_dir do
    mode '0700'
    recursive true
    not_if { ::File.directory?(state_dir) }
  end

  remote_file archive do
    source new_resource.source
    checksum new_resource.checksum if new_resource.checksum
  end

  archive_file archive do
    destination build
    strip_components 1
    overwrite false
    not_if { provider.installation_current?(prefix, manifest, fingerprint) }
  end

  bash "build Vim #{new_resource.version} for #{new_resource.prefix}" do
    cwd build
    code <<~BUILD
      set -e
      ./configure #{Shellwords.join(new_resource.configuration + ["--prefix=#{new_resource.prefix}"])}
      make -j#{new_resource.jobs}
      make install DESTDIR=#{Shellwords.escape(stage)}
    BUILD
    not_if { provider.installation_current?(prefix, manifest, fingerprint) }
  end

  ruby_block "install staged Vim into #{new_resource.prefix}" do
    block { provider.install_staged(staged_prefix, prefix, manifest, fingerprint) }
    not_if { provider.installation_current?(prefix, manifest, fingerprint) }
  end
end

action :remove do
  provider = self
  manifest = source_manifest
  prefix = new_resource.prefix
  ruby_block "remove managed Vim files from #{new_resource.prefix}" do
    block do
      retained = provider.remove_installation(prefix, manifest)
      Chef::Log.warn("Retained modified Vim files: #{retained.join(', ')}") unless retained.empty?
    end
    only_if { ::File.exist?(manifest) }
  end
end
