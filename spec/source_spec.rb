require 'spec_helper'

describe 'vim::source' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '16.04',
                             file_cache_path: '/var/chef/cache') do |node|
      node.normal['vim']['source']['version'] = 'foo_version_1'
    end.converge(described_recipe)
  end

  it 'uses remote_file resource to download vim tar file' do
    expect(chef_run).to create_remote_file('/var/chef/cache/vim-foo_version_1.tar.bz2')
  end

  it 'uses bash resource to install vim' do
    expect(chef_run).to run_bash('install_vim')
  end

  it 'installs source dependencies' do
    expect(chef_run).to install_package(['exuberant-ctags', 'gcc', 'libncurses5-dev', 'libperl-dev', 'lua5.1', 'make', 'python-dev', 'ruby-dev', 'tcl-dev', 'bzip2'])
  end
end
