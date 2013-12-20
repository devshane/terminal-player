Gem::Specification.new do |gem|
  gem.authors = ['Shane Thomas']
  gem.email = ['shane@devshane.com']
  gem.description = 'A minimalistic terminal-based player for di.fm, somafm.com, and Spotify.'
  gem.summary = 'A minimalistic terminal-based player for di.fm, somafm.com, and Spotify.'
  gem.homepage = 'https://github.com/devshane/terminal-player'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['terminal_player']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.name = 'terminal_player'
  gem.version = '0.0.5'
  gem.date = '2013-12-15'
  gem.licenses = ['MIT']

  gem.require_paths = ['lib']
end
