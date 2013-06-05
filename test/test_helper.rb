gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'
require_relative '../lib/hull'

def reset_package_index!
  Hull::PackageIndex.default.clear!
end