# frozen_string_literal: true

require 'spec_helper'

describe 'vim_package' do
  platform 'ubuntu', '24.04'
  step_into :vim_package

  context 'installation' do
    recipe do
      vim_package 'editor' do
        extra_packages ['vim-doc']
      end
    end

    it 'installs the platform editor and requested extras' do
      expect(chef_run).to install_package('vim')
      expect(chef_run).to install_package('vim-doc')
    end
  end

  context 'RHEL packages' do
    platform 'redhat', '9'
    recipe { vim_package 'editor' }

    it 'installs the vi and full vim packages used by the old recipe' do
      expect(chef_run).to install_package(%w(vim-minimal vim-enhanced))
    end
  end

  context 'removal' do
    recipe do
      vim_package 'editor' do
        extra_packages ['vim-doc']
        action :remove
      end
    end

    it 'removes the editor and explicitly managed extras' do
      expect(chef_run).to remove_package('vim')
      expect(chef_run).to remove_package('vim-doc')
    end
  end
end
