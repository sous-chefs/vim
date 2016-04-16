name 'vim'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Installs vim and optional extra packages.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '2.0.1'

%w(debian ubuntu arch redhat centos fedora scientific oracle amazon zlinux).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/vim' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/vim/issues' if respond_to?(:issues_url)
