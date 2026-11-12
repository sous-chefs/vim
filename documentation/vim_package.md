# vim_package

Install the distribution's Vim package, with optional extra packages.

## Actions

* `:install` (default): install the editor packages and requested extras.
* `:remove`: remove those same explicitly managed packages and extras.

## Properties

* `packages` (Array): defaults to `vim-minimal` and `vim-enhanced` on RHEL and
  Fedora, and `vim` elsewhere. This preserves the previous package recipe.
* `extra_packages` (Array): additional packages, empty by default. Verify that
  they exist in the target distribution's configured repositories.

```ruby
vim_package 'editor' do
  extra_packages ['vim-doc']
end
```

Pass the same packages and extras when removing a customised installation.
