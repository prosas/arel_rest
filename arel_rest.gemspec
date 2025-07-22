Gem::Specification.new do |s|
  s.name        = "arel_rest"
  s.version     = "1.2.0"
  s.date        = "2023-04-19"
  s.summary     = "REST API interface for building ActiveRecord queries."
  s.description = "Provides a simple REST API interface for dynamically constructing SQL queries using ActiveRecord. Expose powerful query capabilities to client applications while maintaining full control over query logic and security."
  s.authors     = ["Luiz Filipe, Lucas Hunter, Leonardo Baptista, Rafael C. Abreu"]
  s.email       = "luizfilipeneves@gmail.com"
  s.files       = ["lib/arel_rest.rb"]
  s.require_paths = ["lib"]
  s.homepage    = "https://github.com/luizfilipecosta/arel_rest"
  s.license     = "MIT"
  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.required_ruby_version = '>= 2.7.0'
  s.add_runtime_dependency "activesupport", ["~> 6", "~> 7", "~> 8"]
  s.add_development_dependency "rake", ["~> 13"]
  s.add_development_dependency "sqlite3", ["~> 2"]
  s.add_development_dependency "minitest", ["~> 5"]
  s.add_development_dependency "byebug", ["~> 11"]
  s.add_development_dependency "database_cleaner-active_record", ["~> 2"]
end
