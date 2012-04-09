# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zen_config/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gauthier Delacroix"]
  gem.email         = ["gauthier.delacroix@gmail.com"]
  gem.description   = "Zend_Config translated into Ruby"
  gem.summary       = "Brings Ruby config objects as with Zend Framework's Zend_Config"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "zen_config"
  gem.require_paths = ["lib"]
  gem.version       = ZenConfig::VERSION

  gem.add_development_dependency "rspec"
end
