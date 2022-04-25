unified_mode true

include Vim::Cookbook::Helpers

property :version,
          String,
          default: '8.2'

property :checksum,
          String,
          default: 'f087f821831b4fece16a0461d574ccd55a8279f64d635510a1e10225966ced3b'

property :configuration,
          String,
          default: "--without-x --enable-pythoninterp --enable-rubyinterp --enable-tclinterp --enable-luainterp --enable-perlinterp --enable-cscope  --with-features=huge --prefix=#{new_resource.prefix}"

property :prefix,
          String,
          default: '/usr/local'

property :dependencies,
          Array,
          default: vim_source_dependencies

action :install do
  cache_path = Chef::Config['file_cache_path']

  package new_resource.dependencies

  if platform_family?('fedora', 'rhel', 'amazon') && node['platform_version'].to_i >= 7
    link '/usr/share/perl5/ExtUtils/xsubpp' do
      to '/usr/bin/xsubpp'
      only_if { ::File.exist?('/usr/bin/xsubpp') } # if package node attributes don't include perl this won't be here
    end

    package %w(bzip2)
  end

  remote_file "#{cache_path}/vim-#{new_resource.version}.tar.bz2" do
    source "http://ftp.vim.org/pub/vim/unix/vim-#{new_resource.version}.tar.bz2"
    checksum new_resource.checksum
  end

  bash 'install_vim' do
    cwd cache_path
    code <<-EOH
      mkdir vim-#{new_resource.version}
      tar -jxf vim-#{new_resource.version}.tar.bz2 -C vim-#{new_resource.version} --strip-components 1
      (cd vim-#{new_resource.version}/ && make clean && ./configure #{new_resource.configuration} && make && make install)
    EOH
    creates "#{new_resource.prefix}/bin/vim"
  end
end
