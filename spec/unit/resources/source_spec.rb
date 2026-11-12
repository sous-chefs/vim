# frozen_string_literal: true

require 'spec_helper'

describe 'vim_source' do
  platform 'debian', '12'
  step_into :vim_source

  recipe do
    vim_source 'editor' do
      dependencies ['custom-build-dependency']
      configuration '--without-x --with-features=huge'
    end
  end

  it 'keeps the upstream default installation prefix' do
    configure = chef_run.bash('build Vim 9.2.1332 for /usr/local').code.lines[1]
    expect(Shellwords.split(configure)).to include('--prefix=/usr/local')
  end

  it 'stages upstream installation instead of running the recursive upstream uninstaller' do
    expect(chef_run.bash('build Vim 9.2.1332 for /usr/local').code).to include('make install DESTDIR=')
    expect(chef_run.bash('build Vim 9.2.1332 for /usr/local').code).not_to include('make uninstall')
  end

  it 'respects caller build dependencies' do
    is_expected.to install_package(['custom-build-dependency'])
  end

  context 'Fedora Tcl compatibility' do
    platform 'fedora'

    recipe do
      node.automatic['platform_version'] = '42'
      vim_source 'editor'
    end

    it 'uses the vendor Tcl 8 headers required by the Vim interpreter' do
      expect(chef_run.vim_source('editor').dependencies).to include('tcl8-devel')
      expect(chef_run.vim_source('editor').dependencies).not_to include('tcl-devel')
      expect(chef_run.vim_source('editor').configuration).to include('--with-tclsh=tclsh8.6')
    end
  end

  context 'an unsafe prefix' do
    recipe do
      vim_source 'editor' do
        prefix '/'
      end
    end

    it 'rejects the filesystem root before installing anything' do
      expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed, /must not be the filesystem root/)
    end
  end
end
