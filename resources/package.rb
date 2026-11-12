# frozen_string_literal: true

provides :vim_package
unified_mode true

property :packages, Array, default: lazy {
  platform_family?('rhel', 'fedora') ? %w(vim-minimal vim-enhanced) : ['vim']
}
property :extra_packages, Array, default: []

default_action :install

action :install do
  package new_resource.packages
  package new_resource.extra_packages unless new_resource.extra_packages.empty?
end

action :remove do
  package new_resource.packages do
    action :remove
  end

  unless new_resource.extra_packages.empty?
    package new_resource.extra_packages do
      action :remove
    end
  end
end
