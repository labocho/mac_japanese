# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mac_japanese/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["labocho"]
  gem.email         = ["labocho@penguinlab.jp"]
  gem.description   = %q{Convert MacJapanese string to UTF-8 and vice versa.}
  gem.summary       = %q{Convert MacJapanese string to UTF-8 and vice versa.}
  gem.homepage      = "https://github.com/labocho/mac_japanese"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mac_japanese"
  gem.require_paths = ["lib"]
  gem.version       = MacJapanese::VERSION
  gem.add_development_dependency "rspec", "~>2.11.0"
  gem.add_development_dependency "guard-rspec", "~>0.7.0"
  gem.add_development_dependency "ruby-debug19"
end
