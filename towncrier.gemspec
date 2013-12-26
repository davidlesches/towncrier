$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "towncrier/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "towncrier"
  s.version     = Towncrier::Version::VERSION
  s.authors     = [ 'David Lesches' ]
  s.email       = [ 'david@lesches.com' ]
  s.homepage    = 'https://github.com/davidlesches/towncrier'
  s.summary     = "TO ADD: Summary of Towncrier."
  s.description = "TO ADD: Description of Towncrier."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "private_pub"

  s.add_development_dependency "sqlite3"
end
