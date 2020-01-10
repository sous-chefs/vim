require 'spec_helper'

describe 'vim::source' do
  context 'on ubuntu' do
    platform 'ubuntu'

    it { is_expected.to install_package(['exuberant-ctags', 'gcc', 'libncurses5-dev', 'libperl-dev', 'lua5.1', 'make', 'python-dev', 'ruby-dev', 'tcl-dev', 'bzip2']) }
  end

  context 'on rhel 7' do
    platform 'redhat', '7'

    it { is_expected.to install_package(%w(ctags gcc lua-devel make ncurses-devel perl-devel perl-ExtUtils-CBuilder perl-ExtUtils-Embed perl-ExtUtils-ParseXS python-devel ruby-devel tcl-devel bzip2)) }
  end

  context 'on rhel 8' do
    platform 'redhat', '8'

    it { is_expected.to install_package(%w(ctags gcc lua-libs make ncurses-devel perl-devel perl-ExtUtils-CBuilder perl-ExtUtils-Embed perl-ExtUtils-ParseXS python3-libs ruby-devel tcl-devel bzip2)) }
  end

  context 'on sles' do
    platform 'suse'

    it { is_expected.to install_package(%w(ctags gcc lua-devel make ncurses-devel perl python-devel ruby-devel tcl-devel tar)) }
  end
end
