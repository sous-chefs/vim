# Vim custom resource migration

## Owner scope

The owner selected a full custom-resource migration and replacement major
release. The current patch release PR must not publish recipe/attribute API
removal. Complete both package and source journeys before proposing the
migration as finished.

## Verified source distribution

Vim states that its FTP mirror was retired with Vim 9.1 and recommends GitHub:
<https://www.vim.org/sources.php>. The vendor mirror list includes
<https://ftp.nluug.nl/pub/vim/> at <https://www.vim.org/mirrors.php>.

On 2026-11-12, downloading
`https://ftp.nluug.nl/pub/vim/unix/vim-8.2.tar.bz2` succeeded and produced
SHA-256 `f087f821831b4fece16a0461d574ccd55a8279f64d635510a1e10225966ced3b`,
identical to the old recipe pin. This mirror is an option for explicit legacy
source installations, not evidence that Vim 8.2 is a maintained default.
The same mirror returned 404 for Vim 9.2; do not assume its archive continues
to receive new releases.

Vim's current download page recommends Vim 9.2:
<https://www.vim.org/download.php>. Immutable source tags are available from
the official repository at <https://github.com/vim/vim>. Verify the exact tag
and checksum used by the new source resource; a Git tag need not have a
corresponding GitHub release object.

## Existing behaviour and migration constraints

The package recipe installs `vim` on most platforms and
`vim-minimal`/`vim-enhanced` on RHEL and Fedora. `vim_package` preserves this
mapping and makes extras explicit resource properties. It uses the native
package resource for install and remove.

The old source recipe installs directly into shared `/usr/local`, has no
installation manifest and guards only on the existence of `bin/vim`. It can
neither safely remove an installation nor detect version/configuration drift.
Its dependency names include Python 2-era packages. A new source resource
needs a tested current dependency contract and a safe prefix/manifest design;
do not claim source cleanup or idempotency based on a single binary marker.

Never recursively remove pre-existing prefix contents. Preserve user-modified
files. Keep compiler dependencies installed during removal; they may be shared
with unrelated applications.

## Test notes

ChefSpec resolves only this local cookbook through a temporary cookbook path.
It must not scan sibling checkouts or resolve unrelated Supermarket cookbooks.
Unit tests can establish resource declarations and package selection but cannot
prove a source build or idempotent installation. Run actual Linux Kitchen
convergence and removal before acceptance.

## Source ownership decision and upstream uninstall

The owner confirmed upstream's default `/usr/local` location. Do not move the
installation to a new private prefix. The owner permits staging and a per-file
manifest only where needed to prove safe removal; if that cannot be proved,
leave removal unsupported and report the limitation.

The verified Vim 8.2 `src/Makefile` defines `uninstall_runtime` with recursive
removal of runtime trees including `DEST_MACRO`, `DEST_PACK`, `DEST_SPELL` and
`DEST_LANG`, plus wildcard deletion of added syntax files. Therefore `make
uninstall` does not satisfy the requirement to preserve unrelated files.
Vim supports `make install DESTDIR=...` for staging without changing its
compiled prefix (official `runtime/doc/version6.txt`; also verified the
Makefile's DESTDIR-derived paths). Any manifest implementation must preserve
modified files, symlink safety, unrelated content and pre-existing directories;
it must prove creation, repeat convergence and removal in Linux acceptance.

The current official source tag verified through the GitHub tags API on
2026-11-12 is `v9.2.1332`. Its official GitHub tag archive at
`https://github.com/vim/vim/archive/refs/tags/v9.2.1332.tar.gz` downloaded
successfully, with SHA256
`3cd253ad44a42be755579174e4554e20bc7863abf82fb2de5a6914f3e8a2f617`.
The archive root is `vim-9.2.1332`. The current Makefile still documents the
default prefix as `/usr/local` and still recursively deletes runtime trees in
`uninstall_runtime`. Preserve explicit source/configuration overrides.

## Source candidate and acceptance

The source candidate uses upstream `make install DESTDIR=...` under the build
cache, then copies only staged files into the unchanged installation prefix.
Its manifest records file hashes, symbolic-link targets and newly created
directories. A changed configuration, source or build dependency fingerprint
rebuilds the source. A receipt alone does not prove current state: the guard
checks all currently managed files against actual disk contents. Modified
managed files block another install rather than being overwritten silently.

Removal unlinks only matching managed files or links and prunes only recorded
empty directories. Modified files, replaced symlink parents, unrelated files
and pre-existing directories are retained. No recursive installed-tree delete
is used. Missing manifests cause removal to do nothing; never reconstruct
ownership by guessing from a Vim executable. Build dependencies and cache
artifacts are retained, as is the shared state directory.

Persistent receipts default to `/var/lib/vim-cookbook`, with `state_dir` exposed
for callers. Chef's file cache is unsuitable for durable receipts: Dokken
replaces it between separate Kitchen convergences, which was demonstrated by
the first removal test refusing to delete the untracked installation. The
candidate now uses the persistent location. Fresh Debian acceptance passed:
creation has 11 assertions and a zero-update second convergence (0/9);
separate removal has four assertions and a zero-update second convergence
(0/3), retaining both the modified help file and unrelated runtime content.

Native `archive_file strip_components` requires Chef 17.5 or newer; this raises
the minimum in the replacement major release. Source defaults replace Python
2 integration with Python 3 while retaining Ruby, Tcl, Lua, Perl, cscope and
huge features. Debian needs both `lua5.4` and `liblua5.4-dev` because configure
uses the executable to detect the version. The initial real build lacked Lua;
the corrected build passed all 11 creation assertions and a zero-update second
convergence before and after the persistent-receipt acceptance reset.

The package workflow also passed on Debian 12 and current openSUSE Leap 16,
with zero-update second convergences. Debian package removal passed separately,
again with zero updates on repeat. The current SUSE image is the official
`opensuse/leap:16.0`; Vim has no service requirement, so it runs with `sleep`
as PID 1. Vendor platform/architecture information is at
<https://get.opensuse.org/leap/16.0/>; Leap 15.6 ended standard support on
2026-04-30, while Leap 16 is maintained through 2027-10-31, verified at
<https://endoflife.date/opensuse>. Retain all declared runtime platform families.

The old private macOS 10.12 VMware fixture is preserved under
`documentation/macos-10.12-kitchen.yml` as an unmaintained historical reference.
It is not current acceptance evidence or a new macOS support declaration.
The unused Windows exec template is removed; Windows was not a declared
platform or active integration target. Canonical maintained Linux platforms
match between kitchen.yml, kitchen.dokken.yml and the CI matrix.

SUSE source acceptance first failed during a local Policyfile export before
Chef ran; rerunning sequentially reached the actual package check. That check
demonstrated `perl-ExtUtils-Embed` has no SUSE candidate. Querying the official
Leap 16 repository showed `perl` provides `perl(ExtUtils::Embed)`, so the
candidate uses that existing provider rather than a RHEL-specific package.
The next real run compiled successfully but detected repeated updates for
virtual `lua`/`lua-devel` names. The official repository lists concrete
`lua54`/`lua54-devel` packages; installing them in a separate disposable
container verified that vendor alternatives provide `/usr/bin/lua` and its
development library, without cookbook-created global symlinks. Use those
concrete names so native zypper state can converge idempotently.
Do not claim the SUSE source journey passed until its real run completes.

The corrected concrete-Lua SUSE run now passed all 11 assertions and reached
zero updates on its second convergence (0/9). The directory-mode regression
also proved that a restrictive umask must not make newly installed runtime
directories private; only newly created directories receive their staged
modes, while existing directory permissions remain unchanged. All 18 unit
tests pass. Broader hosted matrix acceptance still gates merging.

File-protection v3 is target-event-only. Its exact reusable/action code was
audited during the DHCP repair: API reads/optional PR closure only, no PR code
checkout, execution or PR-text shell interpolation. The caller uses minimal
pull-request write permission and opened/reopened/synchronize events; body
edits from blacksmith-sh[bot] must not cause actor-based file-protection
failures. Observe a real default-branch target run after bootstrap before
merging the replacement release. A missing pre-bootstrap check is not a pass.
