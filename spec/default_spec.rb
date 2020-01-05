require 'spec_helper'

describe 'vim::default' do
  platform 'ubuntu'

  it 'should include the vim::package recipe when install_method = "package"' do
    is_expected.to include_recipe('vim::package')
  end

  context 'when install_method = "source"' do
    override_attributes['vim']['install_method'] = 'source'

    it 'should include the vim::source recipe' do
      is_expected.to include_recipe('vim::source')
    end
  end
end
