unified_mode true

property :name, name_property: true
property :extra_packages, Array, default: []

action :install do
  vim_base_pkgs = value_for_platform_family(
    %w(debian arch) => ['vim'],
    %w(rhel fedora) => %w(vim-minimal vim-enhanced),
    'default' => ['vim']
  )

  package vim_base_pkgs

  package new_resource.extra_packages unless new_resource.extra_packages.empty?
end
