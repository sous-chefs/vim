#
# Cookbook:: vim
# Attributes:: source
#
# Copyright:: 2013-2020, Chef Software, Inc.
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

default['vim']['source']['version']       = '8.2'
default['vim']['source']['checksum']      = 'f087f821831b4fece16a0461d574ccd55a8279f64d635510a1e10225966ced3b'
default['vim']['source']['prefix']        = '/usr/local'
default['vim']['source']['configuration'] = "--without-x --enable-pythoninterp --enable-rubyinterp --enable-tclinterp --enable-luainterp --enable-perlinterp --enable-cscope  --with-features=huge --prefix=#{default['vim']['source']['prefix']}"

default['vim']['source']['dependencies'] = if platform_family?('rhel', 'fedora', 'amazon')
                                             if platform_family?('rhel') && node['platform_version'].to_i >= 8
                                               %w( ctags
                                                   gcc
                                                   lua-libs
                                                   make
                                                   ncurses-devel
                                                   perl-devel
                                                   perl-ExtUtils-CBuilder
                                                   perl-ExtUtils-Embed
                                                   perl-ExtUtils-ParseXS
                                                   python3-libs
                                                   ruby-devel
                                                   tcl-devel
                                                   bzip2
                                                                                      )
                                             else
                                               %w( ctags
                                                   gcc
                                                   lua-devel
                                                   make
                                                   ncurses-devel
                                                   perl-devel
                                                   perl-ExtUtils-CBuilder
                                                   perl-ExtUtils-Embed
                                                   perl-ExtUtils-ParseXS
                                                   python-devel
                                                   ruby-devel
                                                   tcl-devel
                                                   bzip2
                                                                                      )

                                             end
                                           elsif platform_family?('suse')
                                             %w( ctags
                                                 gcc
                                                 lua-devel
                                                 make
                                                 ncurses-devel
                                                 perl
                                                 python-devel
                                                 ruby-devel
                                                 tcl-devel
                                                 tar
                                                                                        )
                                           else
                                             %w( exuberant-ctags
                                                 gcc
                                                 libncurses5-dev
                                                 libperl-dev
                                                 lua5.1
                                                 make
                                                 python-dev
                                                 ruby-dev
                                                 tcl-dev
                                                 bzip2
                                                                                        )
                                           end
