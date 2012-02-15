$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "turbogrid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "turbogrid"
  s.version     = Turbogrid::VERSION
  s.authors     = ["Emil Loer"]
  s.email       = ["emil@koffietijd.net"]
  s.homepage    = "https://github.com/thedjinn/turbogrid"
  s.summary     = "The fastest way to add sortable tables to a Rails 3 app."
  s.description = "The fastest way to add sortable tables to a Rails 3 app."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.0"
  s.add_dependency "kaminari"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec", "~> 2.0"
end
