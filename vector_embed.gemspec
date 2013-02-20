# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vector_embed/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "vector_embed"
  gem.version       = VectorEmbed::VERSION
  gem.authors       = ["Seamus Abshere"]
  gem.email         = ["seamus@abshere.net"]
  gem.description   = %q{Vector embedding of strings, booleans, numerics, and arrays into LIBSVM / LIBLINEAR format.}
  gem.summary       = %q{Vector embedding of strings, booleans, numerics, and arrays into LIBSVM / LIBLINEAR format.}
  gem.homepage      = "https://github.com/seamusabshere/vector_embed"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'murmurhash3'
  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'yard'
end
