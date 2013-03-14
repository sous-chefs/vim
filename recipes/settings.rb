#
# Cookbook Name:: vim
# Attributes:: default
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

# This recipe is used to configure vim with personal .vim and .vimrc files.

include_recipe 'git'

home_dir   = node['vim']['settings']['home']
vim_folder = node['vim']['settings']['dir']
vim_source = node['vim']['settings']['source']
vim_user   = node['vim']['settings']['user']
source_ref = node['vim']['settings']['ref']

git "#{home_dir}/#{vim_folder}" do
  repository vim_source
  reference  source_ref
  action     :checkout
  user       vim_user

  enable_submodules true
end

bash "link-vimrc" do
  cwd home_dir
  user vim_user
  code <<-EOF
    (cd #{vim_folder})
    (ln -s #{home_dir}/#{vim_folder}/.vimrc #{home_dir}/.vimrc)
  EOF
  not_if { ::File.exists?("#{home_dir}/.vimrc") }
end
