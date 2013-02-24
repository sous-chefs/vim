Description
===========

Installs or compiles/installs vim.

Requirements
============

## Platform:

* Ubuntu/Debian
* Red Hat/CentOS/Fedora/Scientific
* ArchLinux

## Dependencies:

* The compile recipe uses the mercurial cookbook.
* The settings recipe uses the git cookbook.

Attributes
==========

## Default recipe attributes:

* `node[:vim][:extra_packages]` - An array of extra packages related to vim to install (like plugins). Empty array by default.

* `node[:vim][:install_method]` - Sets the install method, choose from the various install recipes. This attribute is set to 'package' by default.

* `node[:vim][:use_custom_settings]` - If set to `true` will download some vim settings. This attribute is set to false by default.


## Compile recipe attributes:

* `node[:vim][:compile][:source_path]` - The path were the vim source files will be stored (`/usr/local/src` by default).
* `node[:vim][:compile][:source_url]` -  The url for the vim mercurial repository (this should not change any time soon).
* `node[:vim][:compile][:dependencies]` - These are the non rhl specific devel dependencies for compiling vim.
* `node[:vim][:compile][:centos_dependencies]` - These are the rhl and centos specific depencies needed for compiling vim. 
* `node[:vim][:compile][:prefix]` - This is the path the vim bin will be placed, it's `/usr/local` 
* `node[:vim][:compile][:configuration]` - If you prefer to compile vim differently than the default you can override this configuration.


## Settings attributes:

* `node[:vim][:settings][:source]` - This is the url for the .vim source.
* `node[:vim][:settings][:ref]` - This is just a ref in case master is not an option.
* `node[:vim][:settings][:dir]` - This is the name of the dir for .vim (in windows it needs to be called vimfiles).
* `node[:vim][:settings][:user]` - This is the name of user that we will add this .vim to (it is set to the vagrant user by default).
* `node[:vim][:settings][:home]` - This is the path to the home directory of a user.

Usage
=====

Put `recipe[vim]` in a run list, or `include_recipe 'vim'` to ensure that vim is installed on your systems.

If you would like to install additional vim plugin packages, include their package names in the `node[:vim][:extra_packages]` attribute. Verify that your operating sytem has the package available.

If you would rather compile vim from source, as the case may be for centos nodes, then override the `node[:vim][:compile_from_source]` with a value of `true`.
  

  
License and Author
==================

Author:: Joshua Timberman <joshua@opscode.com>

Copyright 2010, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
