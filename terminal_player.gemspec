Gem::Specification.new do |gem|
  gem.authors = ['Shane Thomas']
  gem.email = ['shane@devshane.com']
  gem.homepage = 'https://github.com/devshane/terminal-player'

  gem.summary = 'A minimalistic terminal-based player for di.fm, somafm.com, and Spotify.'
  gem.description = 'Terminal player is a minimalistic terminal-based player for di.fm, somafm.com, and Spotify.'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['terminal_player']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.name = 'terminal_player'
  gem.version = '0.0.6'
  gem.date = '2013-12-15'
  gem.licenses = ['MIT']

  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency('rake', '~> 10.1.0')
  gem.add_runtime_dependency('rspec', '~> 2.14.1')
  gem.add_runtime_dependency('spotify', '~> 12.5.3')
  gem.add_runtime_dependency('plaything', '~> 1.1.1')
end
