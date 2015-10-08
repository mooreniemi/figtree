$:.push File.expand_path("../lib", __FILE__)
require "figtree/version"

Gem::Specification.new do |gem|
  gem.name    = 'figtree'
  gem.version = Figtree::VERSION
  gem.date    = Date.today.to_s

  gem.summary = "A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects."
  gem.description = "See README.md"

  gem.authors  = ['Alex Moore-Niemi']
  gem.email    = 'moore.niemi@gmail.com'
  gem.homepage = 'https://github.com/mooreniemi/figtree'

  gem.add_dependency('parslet')
  gem.add_development_dependency('rspec', [">= 3.0.0"])

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
end
