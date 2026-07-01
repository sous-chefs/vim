# frozen_string_literal: true

name 'vim'

default_source :supermarket

run_list 'recipe[vim::default]'

cookbook 'vim', path: '.'
cookbook 'apt'
cookbook 'homebrew'

named_run_list :package, 'recipe[vim::default]'
named_run_list :source, 'recipe[vim::default]'
