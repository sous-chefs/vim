#
# Cookbook Name:: vim
# Attributes:: source
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cache_path            = Chef::Config['file_cache_path']
source_version        = node['vim']['source']['version']
source_checksum       = node['vim']['source']['checksum']
install_path          = "#{node['vim']['source']['prefix']}/bin/vim"
compile_configuration = node['vim']['source']['configuration']
dev_dependencies      = node['vim']['source']['dependencies']

dev_dependencies.each do |dependency|
  package dependency do
    action :install
  end
end

remote_file "#{cache_path}/vim-#{source_version}.tar.bz2" do
  source "http://ftp.vim.org/pub/vim/unix/vim-#{source_version}.tar.bz2"
  checksum source_checksum
  notifies :run, "bash[install_vim]", :immediately
end

bash "install_vim" do
  user "root"
  cwd cache_path
  code <<-EOH
    tar -jxf vim-#{source_version}.tar.bz2
    (cd vim-#{source_version}/ && ./configure #{compile_configuration} && make && make install)
  EOH
  action :nothing
end
