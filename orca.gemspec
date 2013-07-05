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
  gem.version       = '0.3.6'
  gem.add_dependency('colored')
  gem.add_dependency('net-ssh')
  gem.add_dependency('net-sftp')
  gem.add_dependency('thor')
end