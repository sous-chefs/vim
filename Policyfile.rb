# frozen_string_literal: true

name 'vim'

default_source :supermarket

run_list 'test::default'

cookbook 'vim', path: '.'
cookbook 'test', path: './test/cookbooks/test'

named_run_list :default, 'test::default'
named_run_list :source, 'test::source'
named_run_list :source_remove, 'test::source_remove'
named_run_list :package_remove, 'test::package_remove'
