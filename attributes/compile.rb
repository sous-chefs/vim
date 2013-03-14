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

default['vim']['compile']['source_path'] = "/usr/local/src"
default['vim']['compile']['source_url']        = 'https://vim.googlecode.com/hg/'
default['vim']['compile']['dependencies']  = %w{ python-dev libncurses5-dev ruby ruby-dev libperl-dev ctags gcc make }
default['vim']['compile']['centos_dependencies']  = %w{ python-devel ncurses ncurses-devel ruby ruby-devel perl-devel ctags gcc make }
default['vim']['compile']['prefix']        = "/usr/local"
default['vim']['compile']['configuration'] = "--without-x --enable-pythoninterp --enable-rubyinterp --enable-cscope  --with-features=huge --prefix=#{default['vim']['compile']['prefix']}"
