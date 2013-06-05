Gem::Specification.new do |gem|
  gem.authors       = ["Andy Kent"]
  gem.email         = ["andy.kent@me.com"]
  gem.description   = %q{Simplified Machine Building}
  gem.summary       = %q{Simplified Machine Building}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hull"
  gem.require_paths = ["lib"]
  gem.version       = '0.1.0'
  gem.add_dependency('colored')
  gem.add_dependency('net-ssh')
  gem.add_dependency('net-sftp')
end