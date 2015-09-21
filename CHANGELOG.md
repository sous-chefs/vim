vim Cookbook CHANGELOG
======================
This file is used to list changes made in each version of the vim cookbook.

v1.1.4 (2015-09-21)
-------------------
- Converted value_for_platform to value_for_platform_family in order to support all RHEL and Debian derivitives
- Added a Kitchen CI config for integration testing
- Updated Travis to test on the latest ruby versions and to perform Chefspec tests
- Updated Berkfile to 3.X format
- Added updated CONTRIBUTING.MD, TESTING.MD and MAINTAINERS.MD files
- Added Chefspec tests to get coverage to 100%
- Added an expanded .gitignore and a chefignore file to limit the files uploaded to the chef-server
- Added a Rakefile for simplified testing
- Resolved rubocop warnings
- Added Oracle Linux and Amazon Linux to the metadata file
- Updated development dependencies
- Updated Kitchen config to work with the latest in Chef DK

v1.1.2 (2013-12-30)
-------------------
* Fixed Ubuntu package installer bug. Adding specs.

v1.1.0
------
### Improvement
- **[COOK-2465](https://tickets.opscode.com/browse/COOK-2465)** - Add a compile and settings optional recipe.
