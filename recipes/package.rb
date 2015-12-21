#
# Cookbook Name:: vim
# Recipe:: package
#
# Copyright 2013-2015, Chef Software, Inc.
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
# There is no vim package on RHEL/CentOS derivatives
# * vim-minimal gives you /bin/vi
# * vim-enhanced gives you /usr/bin/vim
#
vim_base_pkgs = value_for_platform_family(
  %w(debian arch) => ['vim'],
  %w(rhel fedora) => ['vim-minimal', 'vim-enhanced'],
  'default' => ['vim']
)

vim_base_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

unless node['vim']['extra_packages'].empty?
  package node['vim']['extra_packages']
end
