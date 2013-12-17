Gem::Specification.new do |gem|
  gem.authors = ['Shane Thomas']
  gem.email = ['shane@devshane.com']
  gem.description = 'A terminal-based player for di.fm and somafm.com'
  gem.summary = 'A terminal-based player for di.fm and somafm.com'
  gem.homepage = 'https://github.com/devshane/terminal-player'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.name = 'terminal-player'
  gem.version = '0.0.1'
  gem.date = '2013-12-15'
  gem.licenses = ['MIT']

  gem.require_paths = ['lib']
end
