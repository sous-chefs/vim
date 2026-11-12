# frozen_string_literal: true

# Build repositories are acceptance-fixture prerequisites, not production policy.
if platform_family?('rhel') && !platform?('amazon')
  major = node['platform_version'].to_i
  build_repo = if platform?('oracle')
                 "ol#{major}_codeready_builder"
               else
                 major == 8 ? 'powertools' : 'crb'
               end

  package 'dnf-plugins-core'
  dnf_package 'refresh Vim build repository metadata' do
    action :nothing
  end

  execute 'enable Vim build repository' do
    command "dnf config-manager --set-enabled #{build_repo}"
    notifies :flush_cache, 'dnf_package[refresh Vim build repository metadata]', :immediately
    not_if "dnf repolist --enabled --quiet | grep -q \"^#{build_repo}[[:space:]]\""
  end

  if major == 9
    package(platform?('oracle') ? 'oracle-epel-release-el9' : 'epel-release')
    if platform?('oracle')
      execute 'enable Oracle EPEL repository' do
        command 'dnf config-manager --set-enabled ol9_developer_EPEL'
        notifies :flush_cache, 'dnf_package[refresh Vim build repository metadata]', :immediately
        not_if 'dnf repolist --enabled --quiet | grep -q "^ol9_developer_EPEL[[:space:]]"'
      end
    end
  end
end

directory '/usr/local/share/vim/vim92/doc' do
  recursive true
end
file '/usr/local/share/vim/vim92/doc/chef-unrelated.txt' do
  content 'Retain this unrelated runtime file.'
end

vim_source 'editor'
