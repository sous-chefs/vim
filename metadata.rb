name 'vim'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Installs vim and optional extra packages.'
version '2.1.0'

%w(debian ubuntu redhat centos fedora scientific oracle amazon zlinux suse opensuse opensuseleap).each do |os|
  supports os
end

source_url 'https://github.com/chef-cookbooks/vim'
issues_url 'https://github.com/chef-cookbooks/vim/issues'
chef_version '>= 12.15'
