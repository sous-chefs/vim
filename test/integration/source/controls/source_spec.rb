# frozen_string_literal: true

control 'vim-source-installation' do
  describe file('/usr/local/bin/vim') do
    it { should be_file }
    it { should be_executable }
  end

  describe command('/usr/local/bin/vim --version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/VIM - Vi IMproved 9\.2/) }
    %w(python3 ruby tcl lua perl).each do |feature|
      its('stdout') { should match(/\+#{feature}\b/) }
    end
  end

  describe command("/usr/local/bin/vim -Nu NONE -n -es -c 'syntax on' -c 'qall'") do
    its('exit_status') { should eq 0 }
  end

  describe file('/usr/local/share/vim/vim92/doc/chef-unrelated.txt') do
    its('content') { should eq 'Retain this unrelated runtime file.' }
  end
end
