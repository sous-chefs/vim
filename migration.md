# Migrating to custom resources

This is a major release. It removes `vim::default`, `vim::package`,
`vim::source`, `vim::source_rhel` and their node attributes. Chef 17.5 or newer
is required for native archive extraction with `strip_components`.

Replace the default or package recipe with:

```ruby
vim_package 'editor' do
  extra_packages ['vim-doc']
end
```

Replace the source recipe with:

```ruby
vim_source 'editor' do
  prefix '/usr/local'
end
```

Map `node['vim']['extra_packages']` to `vim_package.extra_packages`. Map the
source version, checksum, dependencies, prefix and configuration attributes to
the corresponding `vim_source` properties. `install_method` becomes the choice
between the two resources. Pass the same prefix and persistent state directory
when invoking `:remove`.

The source default moves from Vim 8.2 at a retired FTP endpoint to the verified
official Vim 9.2.1332 tag archive. The checksum is pinned. Python 3 replaces
Python 2 integration; Ruby, Tcl, Lua, Perl, cscope and huge features remain
enabled by default. Review custom build dependencies and configuration. The
old RHEL-specific global Perl helper symlink is no longer created.

The installation stays in upstream's `/usr/local` location. Persistent
manifests in `/var/lib/vim-cookbook` track staged files and their hashes; Chef's
cache is not durable enough for this state. Keep the manifests when clearing
build caches. Removal never invokes upstream's recursive `make uninstall`,
never removes untracked files, and retains modified files. An existing legacy
installation has no receipt and is not guessed to be removable.

The test policy now uses local test cookbooks and separate creation/removal
profiles. Runtime platform declarations remain, while obsolete versions are
removed from CI. Historical private macOS test configuration remains as an
unmaintained reference, without a current macOS support or acceptance claim.
