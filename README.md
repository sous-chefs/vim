# vim Cookbook

[![CI](https://github.com/sous-chefs/vim/actions/workflows/ci.yml/badge.svg)](https://github.com/sous-chefs/vim/actions/workflows/ci.yml) [![Cookbook Version](https://img.shields.io/cookbook/v/vim.svg)](https://supermarket.chef.io/cookbooks/vim)

Installs or compiles/installs vim.

## Requirements

### Platforms

- Ubuntu/Debian
- RHEL/CentOS/Scientific/Amazon/Oracle
- Fedora
- openSUSE / SUSE Linux Enterprises

### Chef

- Chef 17.5+ for native archive extraction with `strip_components`.

### Cookbooks

- none

## Resources

- [vim_package](documentation/vim_package.md): install or remove distribution packages and optional extras.
- [vim_source](documentation/vim_source.md): build upstream Vim at its default `/usr/local` prefix, with safe manifest-based removal.

## Usage

```ruby
vim_package 'editor' do
  extra_packages ['vim-doc']
end
```

Or compile from the pinned upstream source:

```ruby
vim_source 'editor'
```

Recipes and node attributes are removed in this major release. Follow the
[migration guide](migration.md) to replace existing callers. Source removal
preserves unrelated and locally modified files; it never recursively deletes
the shared installation prefix.

## License & Authors

**Author:** Cookbook Engineering Team ([cookbooks@chef.io](mailto:cookbooks@chef.io))

**Copyright:** 2008-2016, Chef Software, Inc.

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
