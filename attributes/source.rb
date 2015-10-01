#
# Cookbook Name:: vim
# Attributes:: source
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

default['vim']['source']['version']       = '7.4'
default['vim']['source']['checksum']      = 'd0f5a6d2c439f02d97fa21bd9121f4c5abb1f6cd8b5a79d3ca82867495734ade'
default['vim']['source']['prefix']        = '/usr/local'
default['vim']['source']['configuration'] = "--without-x --enable-pythoninterp --enable-python3interp --enable-rubyinterp --enable-tclinterp --enable-luainterp --enable-perlinterp --enable-cscope  --with-features=huge --prefix=#{default['vim']['source']['prefix']}"

if platform_family? 'rhel', 'fedora'
  default['vim']['source']['dependencies']  = %w(python-devel ncurses-devel ruby-devel perl-devel perl-ExtUtils-Embed perl-ExtUtils-ParseXS perl-ExtUtils-XSpp perl-ExtUtils-CBuilder ctags gcc make)
else
  default['vim']['source']['dependencies']  = %w( exuberant-ctags
                                                  gcc
                                                  libncurses5-dev
                                                  libperl-dev
                                                  lua5.1
                                                  make
                                                  python3-dev
                                                  python-dev
                                                  ruby-dev
                                                  tcl-dev
                                              )
end
