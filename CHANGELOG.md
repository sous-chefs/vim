# vim Cookbook CHANGELOG

This file is used to list changes made in each version of the vim cookbook.

## [4.0.0](https://github.com/sous-chefs/vim/compare/v3.0.3...v4.0.0) (2026-11-12)


### ⚠ BREAKING CHANGES

* migrate Vim to custom resources ([#81](https://github.com/sous-chefs/vim/issues/81))

### Features

* migrate Vim to custom resources ([#81](https://github.com/sous-chefs/vim/issues/81)) ([0eea4f2](https://github.com/sous-chefs/vim/commit/0eea4f2ff946823a84e49e4ce76cea8f2cec0edf))


### Bug Fixes

* **ci:** Update workflows to use release pipeline ([#66](https://github.com/sous-chefs/vim/issues/66)) ([cc96096](https://github.com/sous-chefs/vim/commit/cc960960dfeeb5c10ba8f1832692d3474e28f589))
* migrate to Policyfile and clean up docs ([#74](https://github.com/sous-chefs/vim/issues/74)) ([898dd65](https://github.com/sous-chefs/vim/commit/898dd65048488c479e55b1663e1f8b4779128aa5))
* repair workflow actionlint failures ([#71](https://github.com/sous-chefs/vim/issues/71)) ([12b9ca0](https://github.com/sous-chefs/vim/commit/12b9ca007ec28ef97d042e96dcb3dd8deb9e716f))

## [3.0.3](https://github.com/sous-chefs/vim/compare/3.0.2...v3.0.3) (2025-10-16)


### Bug Fixes

* **ci:** Update workflows to use release pipeline ([#66](https://github.com/sous-chefs/vim/issues/66)) ([cc96096](https://github.com/sous-chefs/vim/commit/cc960960dfeeb5c10ba8f1832692d3474e28f589))

## 3.0.1 - *2024-05-20*

* resolved cookstyle error: metadata.rb:24:1 convention: `Layout/TrailingEmptyLines`

## 3.0.0 - *2024-05-06*

* Adopt cookbook

## 2.1.15 - *2023-04-07*

Standardise files with files in sous-chefs/repo-management

## 2.1.12 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 2.1.11 - *2023-03-20*

Standardise files with files in sous-chefs/repo-management

## 2.1.10 - *2023-03-15*

Standardise files with files in sous-chefs/repo-management

## 2.1.8 - *2023-02-23*

Standardise files with files in sous-chefs/repo-management

## 2.1.6 - *2023-02-14*

Standardise files with files in sous-chefs/repo-management

## 2.1.5 - *2022-12-15*

Standardise files with files in sous-chefs/repo-management

Standardise files with files in sous-chefs/repo-management

## 2.1.4 - *2022-02-07*

* Remove delivery and move to calling RSpec directly via a reusable workflow
* Update tested platforms
* Standardise files with files in sous-chefs/repo-management

## 2.1.3 - *2021-08-30*

* Standardise files with files in sous-chefs/repo-management

## 2.1.2 - *2021-06-01*

* Standardise files with files in sous-chefs/repo-management

## 2.1.1 - *2021-05-28*

* Fix builds

## 2.1.0 (2020-01-10)

* Remove chef 11 compat in metadata - [@tas50](https://github.com/tas50)
* Add support for SLES / opensuse for source installs - [@tas50](https://github.com/tas50)
* Resolve Cookstyle 5.8 warnings - [@tas50](https://github.com/tas50)
* Require Chef 12.15+ - [@tas50](https://github.com/tas50)
* Remove RHEL 5 support for source installs - [@tas50](https://github.com/tas50)
* Add Amazon Linux support for source installs - [@tas50](https://github.com/tas50)
* Update to vim 8.2 for source installs - [@tas50](https://github.com/tas50)
* Fix source installs on RHEL 8 - [@tas50](https://github.com/tas50)

## 2.0.2 (2016-08-30)

* Add IBM zLinux to metadata
* Use kitchen-dokken in Travis CI and test on more Platforms
* Update specs with new platforms
* Remove Chef 11 compatibility
* Add chef_version to metadata

## v2.0.1 (2016-02-22)

* add missing bzip2 package to fix source recipe.

## v2.0.0 (2015-10-01)

* Use multi-package installs introduced in Chef 12.1 to simplify code and speed up installs
* Add Fedora source install support
* Fix CentOS source install support and ensure vim compiles correctly on CentOS 5/6/7
* Fix the tarball checksum to be the actual SHA256 checksum
* Enable lua, perl, tcl support in the source install and add the necessary development packages for that support
* Use the correct ctags package on Debian/Ubuntu systems to prevent errors or warnings
* Improve how the code compilation runs in source installs so that a failed run doesn't prevent subsequent Chef runs or introduce a state where vim is never compiled
* Add basic Serverspec test for source installs to ensure that vim runs
* Fixed the error message is a bad install_method attribute is given to describe the actual problema and vim cookbook

## v1.1.4 (2015-09-21)

* Converted value_for_platform to value_for_platform_family in order to support all RHEL and Debian derivitives
* Added a Kitchen CI config for integration testing
* Updated Travis to test on the latest ruby versions and to perform Chefspec tests
* Updated Berkfile to 3.X format
* Added updated CONTRIBUTING.MD, TESTING.MD and MAINTAINERS.MD files
* Added Chefspec tests to get coverage to 100%
* Added an expanded .gitignore and a chefignore file to limit the files uploaded to the chef-server
* Added a Rakefile for simplified testing
* Resolved rubocop warnings
* Added Oracle Linux and Amazon Linux to the metadata file
* Updated development dependencies
* Updated Kitchen config to work with the latest in Chef DK

## v1.1.2 (2013-12-30)

* Fixed Ubuntu package installer bug. Adding specs.

## v1.1.0

### Improvement

* Add a compile and settings optional recipe.
