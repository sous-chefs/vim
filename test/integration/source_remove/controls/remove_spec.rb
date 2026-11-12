# frozen_string_literal: true

control 'vim-source-removal' do
  describe file('/usr/local/bin/vim') do
    it { should_not exist }
  end
  describe file('/usr/local/bin/view') do
    it { should_not exist }
  end
  describe file('/usr/local/share/vim/vim92/doc/chef-unrelated.txt') do
    its('content') { should eq 'Retain this unrelated runtime file.' }
  end
  describe file('/usr/local/share/vim/vim92/doc/help.txt') do
    its('content') { should eq 'Retain this locally modified managed file.' }
  end
end
