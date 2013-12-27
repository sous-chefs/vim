require 'spec_helper'

describe 'vim::default' do
  it 'should default to install_method = "package"' do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.converge(described_recipe)
    expect(runner.node['vim']['install_method']).to eq('package')
  end

  it 'should include the vim::package recipe when install_method = "package"' do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.converge(described_recipe)
    expect(runner).to include_recipe('vim::package')   
  end

  it 'should include the vim::source recipe when install_method = "source"' do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['vim']['install_method'] = 'source'
    end.converge(described_recipe)
    expect(runner).to include_recipe('vim::source')   
  end
end
