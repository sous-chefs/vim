module Vim
  module Cookbook
    module Helpers
      def vim_source_dependencies
        case platform_family
        when 'rhel', 'fedora', 'amazon'
          packages = %w(perl-devel
            perl-ExtUtils-CBuilder
            perl-ExtUtils-Embed
            perl-ExtUtils-ParseXS
            ncurses-devel
            ruby-devel
            tcl-devel
            bzip2
          )
          packages += if node['platform_version'].to_i >= 8
                        %w(lua-libs python3-libs )
                      else
                        %w(ctags lua-devel python-devel)
                      end
        when platform_family?('suse')
          packages = %w(
                      ctags
                      lua-devel
                      ncurses-devel
                      perl
                      python-devel
                      ruby-devel
                      tcl-devel
                      tar
                      )
        else
          packages = %w(
                      exuberant-ctags
                      libncurses5-dev
                      libperl-dev
                      lua5.1
                      python-dev
                      ruby-dev
                      tcl-dev
                      bzip2
                      )
        end

        default_packages = %w(gcc make)

        packages + default_packages
      end
    end
  end
end
