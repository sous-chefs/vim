# frozen_string_literal: true

directory '/usr/local/share/vim/vim92/doc' do
  recursive true
end
file '/usr/local/share/vim/vim92/doc/chef-unrelated.txt' do
  content 'Retain this unrelated runtime file.'
end

vim_source 'editor'
