# Testing

Use Cinc Workstation and Docker. Resolve the local test cookbooks and run unit
and style checks:

```sh
chef install Policyfile.rb
chef exec rspec
cookstyle
```

Run the default package journey or source journey with two convergences and
their InSpec profiles:

```sh
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen test default-debian-12 --destroy=always
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen test source-debian-12 --destroy=always
```

To verify source removal across separate Chef runs, retain the instance:

```sh
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen converge source-debian-12
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen verify source-debian-12
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml VIM_RUN_LIST=source_remove VIM_VERIFY_PROFILE=source_remove chef exec kitchen converge source-debian-12
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml VIM_RUN_LIST=source_remove VIM_VERIFY_PROFILE=source_remove chef exec kitchen verify source-debian-12 --test-base-path=test/integration/source_remove
env KITCHEN_LOCAL_YAML=kitchen.dokken.yml chef exec kitchen destroy source-debian-12
```

The removal fixture deliberately modifies a managed help file. Its profile
checks that both this file and unrelated runtime content remain, while the
managed executable and links are removed. Persistent manifests stay outside
Chef's disposable file cache. CI also checks native package removal through
the `package_remove` named run list and matching profile.
