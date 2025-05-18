Gem::Specification.new do |s|
  s.name        = "arel_rest"
  s.version     = "1.0.0"
  s.date        = "2023-04-19"
  s.summary     = "A lightweight RESTful interface for building ActiveRecord queries through Arel."
  s.description = "A lightweight RESTful interface for building ActiveRecord queries through Arel."
  s.authors     = ["Lucas Hunter, Luiz Filipe, Leonardo Baptista, Rafael C. Abreu"]
  s.email       = "ops@prosas.com.br"
  s.files       = ["lib/arel_rest.rb"]
  s.require_paths = ["lib"]
  s.homepage    = "https://github.com/luizfilipecosta/arel_rest"
  s.license     = "MIT"
  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.add_runtime_dependency "activesupport", [">= 6"]
  s.add_development_dependency "rake", [">= 13"]
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest", [">= 5"]
  s.add_development_dependency "byebug", [">= 11"]
end
