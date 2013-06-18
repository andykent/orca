gem 'minitest'
require 'minitest/autorun'
require 'mocha/setup'
require_relative '../lib/orca'

def reset_package_index!
  Orca::PackageIndex.default.clear!
end