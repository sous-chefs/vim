require 'spec_helper'

describe 'vim::default' do
  PACKAGE_CHECKS = {
    'ubuntu' => {
      '12.04' => ['vim']
    },
    'debian' => {
      '7.0' => ['vim'],
      '7.1' => ['vim']
    },
    'redhat' => {
      '6.3' => ['vim-minimal', 'vim-enhanced']
    }
  }

  PACKAGE_CHECKS.each do |platform, versions|
    versions.each do |version, packages|
      packages.each do |package_name|
        it "should install #{package_name} on #{platform} #{version}" do
          runner = ChefSpec::Runner.new(platform: platform, version: version) do |node|
            node.set['vim']['install_method'] = 'package'
          end.converge(described_recipe)
          expect(runner).to install_package(package_name)
        end
      end
    end
  end
end
