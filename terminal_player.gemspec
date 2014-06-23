Gem::Specification.new do |gem|
  gem.authors = ['Shane Thomas']
  gem.email = ['shane@devshane.com']
  gem.homepage = 'https://github.com/devshane/terminal-player'

  gem.summary = 'A minimalistic terminal-based player for di.fm and somafm.com.'
  gem.description = 'Terminal player is a minimalistic terminal-based player for di.fm and somafm.com.'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['terminal_player']
  gem.test_files    = gem.files.grep(%r{^(spec)/})

  gem.name = 'terminal_player'
  gem.version = '0.0.8'
  gem.date = '2014-06-23'
  gem.licenses = ['MIT']

  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency 'rake', '~> 10.1', '>= 10.1.1'
  gem.add_runtime_dependency 'rspec', '~> 2.14', '>= 2.14.1'
  gem.add_runtime_dependency 'guard', '~> 2.6', '>= 2.6.1'
  gem.add_runtime_dependency 'guard-rspec', '~> 4.2', '>= 4.2.10'
end
