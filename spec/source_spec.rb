require 'spec_helper'

describe 'vim::source' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu',
                             version: '12.04',
                             file_cache_path: '/var/chef/cache') do |node|
      node.set['vim']['source']['version'] = 'foo_version_1'
      # node.set['vim']['source']['dependencies'] = %w(libncurses5-dev ruby ruby-dev libperl-dev exuberant-ctags liblua5.2-dev gcc make)
    end.converge(described_recipe)
  end

  it 'uses remote_file resource to download vim tar file' do
    expect(chef_run).to create_remote_file('/var/chef/cache/vim-foo_version_1.tar.bz2')
  end

  it 'uses package resource to install bzip2' do
    expect(chef_run).to install_package('bzip2')
  end

  it 'uses bash resource to install vim' do
    expect(chef_run).to run_bash('install_vim')
  end

  # disabling this until there's a clear way to test multipackage installs in Chefspec
  # it 'installs source dependencies' do
  #   chef_run.node['vim']['source']['dependencies'].each do |dep|
  #     expect(chef_run).to install_package(dep)
  #   end
  # end
end
