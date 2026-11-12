# vim_source

Build upstream Vim from a checksum-pinned archive. The default installation
prefix remains `/usr/local`, matching upstream's default.

## Actions

* `:install` (default): install build dependencies, compile into a staging
  directory, then copy the staged file list into the prefix.
* `:remove`: remove only files or symbolic links still matching the persistent
  manifest. Retain locally modified files and unrelated contents. Prune only
  recorded directories that are empty.

## Properties

* `version` (String): `9.2.1332` by default.
* `source` (String): the official GitHub tag archive for the selected version.
* `checksum` (String or nil): the verified SHA256 for the default version. Set
  this explicitly when choosing another source or version.
* `prefix` (String): `/usr/local`. Use an existing parent directory; filesystem
  root and symlink prefixes are rejected to avoid an unrelated installation path.
* `state_dir` (String): `/var/lib/vim-cookbook`. Keep this persistent across
  Chef runs and cache cleanup. It contains one manifest per installation prefix.
* `configuration` (String or Array): configure options; strings are parsed as
  shell words. Defaults enable huge features, Python 3, Ruby, Tcl, Lua, Perl
  and cscope without X. The resource adds the selected prefix last. Keep the
  executable at `bin/vim` under that prefix; separate binary destinations are
  not managed.
* `dependencies` (Array): native build and interpreter development packages
  selected by platform family. Override for custom package repositories or
  configure features. Dependency changes trigger a rebuild.
* `jobs` (positive Integer): parallel make jobs, `2` by default.

```ruby
vim_source 'editor'
```

First installation replaces matching upstream Vim filenames, as `make install`
does. It does not recursively remove prefix contents or adopt unrelated files.
Subsequent installs refuse to overwrite a modified managed file. Move local
customisations outside managed upstream files before upgrading.

Removal requires the manifest produced by this resource. It does nothing if
that manifest is missing and never guesses ownership from an existing binary.
It cannot restore an earlier installation overwritten at the same filename.
Compiler packages, downloaded sources and build caches remain available, and
the shared state directory is retained.

On EL 8, enable the vendor PowerTools or CodeReady Builder repository before
converging. On EL 9, enable CRB or CodeReady Builder and EPEL (Oracle Linux
uses its vendor EPEL repository). These supply Lua development headers and
ctags. The resource does not change repository policy; the acceptance fixture
sets these prerequisites explicitly.

The manifest binds to the canonical installation path. A changed ancestor
symlink causes installation and removal to stop. The state directory and
receipts must belong to the Chef process user and must not be writable by
group or other users; symlinked state directories and receipts are rejected.
Ancestors must have trusted ownership and write permissions (root-owned
sticky temporary directories are allowed). Unsafe existing state is rejected
without changing permissions or deleting its contents.

Fedora 42 and later use the maintained Tcl 8 compatibility headers and
interpreter in the default build. Explicit dependency or configuration
overrides must keep these choices aligned when Tcl support is required.
