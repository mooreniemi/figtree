$:.push File.expand_path("../lib", __FILE__)
require "figtree/version"

Gem::Specification.new do |gem|
  gem.name     = 'figtree'
  gem.version  = Figtree::VERSION
  gem.date     = Date.today.to_s
  gem.licenses = ['MIT']

  gem.summary     = "A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects."
  gem.description = "See README.md"

  gem.authors  = ['Alex Moore-Niemi']
  gem.email    = 'moore.niemi@gmail.com'
  gem.homepage = 'https://github.com/mooreniemi/figtree'

  gem.add_runtime_dependency 'parslet', '~> 1.7'
  gem.add_runtime_dependency 'wannabe_bool', '~> 0.2'
  gem.add_development_dependency 'rspec', '~> 3.0', '"no">= 3.0.0'
  gem.add_development_dependency 'simplecov', '~> 0.10'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
end
