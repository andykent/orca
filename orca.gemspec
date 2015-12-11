Gem::Specification.new do |gem|
  gem.authors       = ["Andy Kent"]
  gem.email         = ["andy.kent@me.com"]
  gem.description   = %q{Orca is a super simple way to build and configure servers}
  gem.summary       = %q{Simplified Machine Building}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "orca"
  gem.require_paths = ["lib"]
  gem.version       = '0.4.1'
  gem.add_dependency('colored')
  gem.add_dependency('net-ssh')
  gem.add_dependency('net-sftp')
  gem.add_dependency('thor')
  gem.add_dependency('tilt')
  gem.post_install_message = %Q[
===================================
The `orca` gem has been deprecated!
-----------------------------------
This gem name is likely to be used
for other purposes, you should lock
your gemfile to version 0.4.0 for
continued usage of this gem.
===================================
  ]
end