# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'tmpdir'
require_relative '../../libraries/source_installation'

describe Vim::SourceInstallation do
  let(:installer) { Object.new.extend(described_class) }

  around do |example|
    Dir.mktmpdir('vim-installation-spec-') do |root|
      @prefix = File.join(root, 'local')
      @stage = File.join(root, 'stage')
      @manifest = File.join(root, 'manifest.json')
      FileUtils.mkdir_p(File.join(@stage, 'bin'))
      File.write(File.join(@stage, 'bin/vim'), 'managed Vim binary')
      File.symlink('vim', File.join(@stage, 'bin/view'))
      example.run
    end
  end

  it 'installs staged files and detects actual content drift independently of its receipt' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    expect(installer.installation_current?(@prefix, @manifest, 'configuration-a')).to be true
    expect(installer.installation_current?(@prefix, @manifest, 'configuration-b')).to be false
    File.write(File.join(@prefix, 'bin/vim'), 'changed')
    expect(installer.installation_current?(@prefix, @manifest, 'configuration-a')).to be false
  end

  it 'removes unchanged managed files and links while retaining unrelated files and directories' do
    FileUtils.mkdir_p(File.join(@prefix, 'bin'))
    File.write(File.join(@prefix, 'bin/unrelated'), 'keep this')
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    expect(installer.remove_installation(@prefix, @manifest)).to be_empty
    expect(File.exist?(File.join(@prefix, 'bin/vim'))).to be false
    expect(File.symlink?(File.join(@prefix, 'bin/view'))).to be false
    expect(File.read(File.join(@prefix, 'bin/unrelated'))).to eq 'keep this'
    expect(File.directory?(File.join(@prefix, 'bin'))).to be true
  end

  it 'retains modified managed files during removal' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    File.write(File.join(@prefix, 'bin/vim'), 'local modification')
    expect(installer.remove_installation(@prefix, @manifest)).to include('bin/vim')
    expect(File.read(File.join(@prefix, 'bin/vim'))).to eq 'local modification'
  end

  it 'refuses to overwrite a modified managed file during another install' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    File.write(File.join(@prefix, 'bin/vim'), 'local modification')
    expect { installer.install_staged(@stage, @prefix, @manifest, 'configuration-b') }.to raise_error(/modified managed file/)
    expect(File.read(File.join(@prefix, 'bin/vim'))).to eq 'local modification'
  end

  it 'removes only directories created by the installation when they are empty' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    installer.remove_installation(@prefix, @manifest)
    expect(File.exist?(@prefix)).to be false
  end

  it 'keeps earlier managed artifacts recorded across an upgrade for later removal' do
    FileUtils.mkdir_p(File.join(@stage, 'share/vim/old-runtime'))
    File.write(File.join(@stage, 'share/vim/old-runtime/file'), 'old runtime')
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    File.unlink(File.join(@stage, 'share/vim/old-runtime/file'))
    File.write(File.join(@stage, 'bin/vim'), 'upgraded Vim binary')
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-b')
    expect(installer.installation_current?(@prefix, @manifest, 'configuration-b')).to be true
    installer.remove_installation(@prefix, @manifest)
    expect(File.exist?(@prefix)).to be false
  end

  it 'refuses an incomplete stage without modifying the destination' do
    File.unlink(File.join(@stage, 'bin/vim'))
    expect { installer.install_staged(@stage, @prefix, @manifest, 'configuration-a') }.to raise_error(%r{does not contain bin/vim})
    expect(File.exist?(@prefix)).to be false
  end

  it 'copies staged directory modes without changing pre-existing directory permissions' do
    FileUtils.mkdir_p(@prefix)
    File.chmod(0o750, @prefix)
    File.chmod(0o755, File.join(@stage, 'bin'))
    original_umask = File.umask(0o077)
    begin
      installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    ensure
      File.umask(original_umask)
    end
    expect(File.stat(File.join(@prefix, 'bin')).mode & 0o777).to eq 0o755
    expect(File.stat(@prefix).mode & 0o777).to eq 0o750
  end

  it 'replaces an existing target symlink without writing through it' do
    outside = File.join(File.dirname(@prefix), 'unrelated')
    File.write(outside, 'keep this')
    FileUtils.mkdir_p(File.join(@prefix, 'bin'))
    File.symlink(outside, File.join(@prefix, 'bin/vim'))
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    expect(File.read(outside)).to eq 'keep this'
    expect(File.symlink?(File.join(@prefix, 'bin/vim'))).to be false
    expect(File.read(File.join(@prefix, 'bin/vim'))).to eq 'managed Vim binary'
  end

  it 'does not follow a replaced parent symlink when removing files' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    original_bin = File.join(@prefix, 'original-bin')
    File.rename(File.join(@prefix, 'bin'), original_bin)
    File.symlink(original_bin, File.join(@prefix, 'bin'))
    expect(installer.remove_installation(@prefix, @manifest)).to include('bin/vim')
    expect(File.read(File.join(original_bin, 'vim'))).to eq 'managed Vim binary'
  end

  it 'rejects a replaced ancestor above the prefix before reading or changing outside files' do
    root = File.dirname(@prefix)
    parent = File.join(root, 'parent')
    @prefix = File.join(parent, 'vim')
    FileUtils.mkdir_p(parent)
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    File.rename(parent, File.join(root, 'original-parent'))
    outside = File.join(root, 'outside')
    FileUtils.mkdir_p(File.join(outside, 'vim/bin'))
    outside_file = File.join(outside, 'vim/bin/vim')
    File.write(outside_file, 'managed Vim binary')
    File.symlink('vim', File.join(outside, 'vim/bin/view'))
    File.symlink(outside, parent)

    expect(installer.installation_current?(@prefix, @manifest, 'configuration-a')).to be false
    expect { installer.install_staged(@stage, @prefix, @manifest, 'configuration-b') }.to raise_error(ArgumentError, /another prefix/)
    expect { installer.remove_installation(@prefix, @manifest) }.to raise_error(ArgumentError, /another prefix/)
    expect(File.read(outside_file)).to eq 'managed Vim binary'
    expect(File.exist?(@manifest)).to be true
  end

  it 'rejects a forged receipt in a writable state directory before removing unrelated files' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    unrelated = File.join(@prefix, 'bin/unrelated')
    File.write(unrelated, 'keep this')
    manifest = JSON.parse(File.read(@manifest))
    manifest['files'] = { 'bin/unrelated' => { 'type' => 'file', 'sha256' => Digest::SHA256.file(unrelated).hexdigest } }
    manifest['directories'] = []
    File.write(@manifest, JSON.generate(manifest))
    File.chmod(0o777, File.dirname(@manifest))

    expect { installer.remove_installation(@prefix, @manifest) }.to raise_error(ArgumentError, /Untrusted Vim state/)
    expect(File.read(unrelated)).to eq 'keep this'
    expect(File.exist?(@manifest)).to be true
  end

  it 'rejects a symlinked receipt rather than trusting its ownership list' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    original = "#{@manifest}.original"
    File.rename(@manifest, original)
    File.symlink(original, @manifest)
    expect { installer.remove_installation(@prefix, @manifest) }.to raise_error(ArgumentError, /Untrusted Vim state/)
    expect(File.read(File.join(@prefix, 'bin/vim'))).to eq 'managed Vim binary'
  end

  it 'rejects a symlinked state directory before installing files' do
    state = File.join(File.dirname(@prefix), 'state')
    File.symlink(File.dirname(@manifest), state)
    manifest = File.join(state, 'receipt.json')
    expect { installer.install_staged(@stage, @prefix, manifest, 'configuration-a') }.to raise_error(ArgumentError, /Untrusted Vim state/)
    expect(File.exist?(@prefix)).to be false
  end

  it 'rejects a receipt writable by other users before removing files' do
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    File.chmod(0o666, @manifest)
    expect { installer.remove_installation(@prefix, @manifest) }.to raise_error(ArgumentError, /Untrusted Vim state/)
    expect(File.read(File.join(@prefix, 'bin/vim'))).to eq 'managed Vim binary'
  end

  it 'uses canonical receipt storage when a writable lexical ancestor changes after validation' do
    root = File.dirname(@prefix)
    secure = File.join(root, 'secure')
    outside = File.join(root, 'outside')
    unsafe = File.join(root, 'unsafe')
    [secure, outside].each { |path| FileUtils.mkdir_p(File.join(path, 'state'), mode: 0o700) }
    FileUtils.mkdir_p(unsafe, mode: 0o777)
    File.chmod(0o777, unsafe)
    @manifest = File.join(secure, 'state/manifest.json')
    installer.install_staged(@stage, @prefix, @manifest, 'configuration-a')
    unrelated = File.join(@prefix, 'bin/unrelated')
    File.write(unrelated, 'keep this')
    forged = JSON.parse(File.read(@manifest))
    forged['files'] = { 'bin/unrelated' => { 'type' => 'file', 'sha256' => Digest::SHA256.file(unrelated).hexdigest } }
    forged['directories'] = []
    outside_manifest = File.join(outside, 'state/manifest.json')
    File.write(outside_manifest, JSON.generate(forged))
    link = File.join(unsafe, 'link')
    File.symlink(secure, link)
    alias_manifest = File.join(link, 'state/manifest.json')
    allow(installer).to receive(:validate_manifest_trust!).and_wrap_original do |method, path|
      canonical = method.call(path)
      if path == alias_manifest
        File.unlink(link)
        File.symlink(outside, link)
      end
      canonical
    end

    installer.remove_installation(@prefix, alias_manifest)
    expect(File.read(unrelated)).to eq 'keep this'
    expect(File.exist?(File.join(@prefix, 'bin/vim'))).to be false
    expect(File.exist?(outside_manifest)).to be true
  end

  it 'refuses paths outside the declared prefix in a damaged receipt' do
    File.write(@manifest, JSON.generate('prefix' => File.join(File.realpath(File.dirname(@prefix)), File.basename(@prefix)), 'files' => { '../unrelated' => { 'type' => 'file', 'sha256' => 'fake' } }, 'directories' => []))
    expect { installer.remove_installation(@prefix, @manifest) }.to raise_error(/outside the installation prefix/)
  end
end
