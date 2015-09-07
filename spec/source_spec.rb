require 'spec_helper'

describe 'vim::source' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '12.04',
                             file_cache_path: '/var/chef/cache') do |node|
      node.set['vim']['source']['version'] = 'foo_version_1'
      node.set['vim']['source']['dependencies'] = %w(libncurses5-dev ruby ruby-dev libperl-dev ctags gcc make)
    end.converge(described_recipe)
  end

  it 'uses remote_file resource to download vim tar file' do
    expect(chef_run).to create_remote_file("/var/chef/cache/vim-#{chef_run.node['vim']['source']['version']}.tar.bz2")
  end

  it 'uses bash resource to install vim' do
    expect(chef_run).to_not run_bash('install_vim')
  end

  it 'installs source dependencies' do
    chef_run.node['vim']['source']['dependencies'].each do |dep|
      expect(chef_run).to install_package(dep)
    end
  end
end
