# frozen_string_literal: true

control 'vim-package-removal' do
  describe package('vim') do
    it { should_not be_installed }
  end
end
