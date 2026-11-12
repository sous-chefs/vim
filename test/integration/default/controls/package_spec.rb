# frozen_string_literal: true

control 'vim-package-installation' do
  describe command('vim --version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/VIM - Vi IMproved/) }
  end
end
