# frozen_string_literal: true

require 'chefspec'
require 'tmpdir'

RSpec.configure do |config|
  cookbook_path = Dir.mktmpdir('vim-chefspec-')
  File.symlink(File.expand_path('..', __dir__), File.join(cookbook_path, 'vim'))
  config.cookbook_path = cookbook_path
  config.after(:suite) { FileUtils.remove_entry(cookbook_path) }
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
end
