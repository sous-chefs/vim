# frozen_string_literal: true

file '/usr/local/share/vim/vim92/doc/help.txt' do
  content 'Retain this locally modified managed file.'
  only_if { ::File.exist?('/usr/local/share/vim/vim92/doc/help.txt') }
end

vim_source 'editor' do
  action :remove
end
