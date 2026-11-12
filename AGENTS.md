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
