require 'spec_helper'

describe 'vim::default' do
  package_checks = {
    'ubuntu' => {
      '14.04' => ['vim'],
      '16.04' => ['vim'],
    },
    'debian' => {
      '7.11' => ['vim'],
      '8.7' => ['vim'],
    },
  }

  package_checks.each do |platform, versions|
    versions.each do |version, packages|
      packages.each do |package_name|
        it "should install #{package_name} on #{platform} #{version}" do
          chef_run = ChefSpec::SoloRunner.new(platform: platform, version: version, file_cache_path: '/var/chef/cache') do |node|
            node.normal['vim']['install_method'] = 'package'
          end.converge(described_recipe)
          expect(chef_run).to install_package(package_name)
        end
      end
    end
  end
end
