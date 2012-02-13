$:.push File.expand_path('../lib', __FILE__)
require 'forgery_protection/version'

Gem::Specification.new do |s|
  s.name = 'strict-forgery-protection'
  s.version  = ForgeryProtection::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [ 'Dmitry Ratnikov' ]
  s.email = [ 'ratnikov@google.com' ]
  s.homepage = 'http://github.com/ratnikov/strict-forgery-protection'
  s.summary = 'Extends Rails to be strict CSRF token protection'

  s.add_dependency 'rails', '~> 3.1'

  s.files = Dir[ 'lib/**/*' ]
  s.test_files = Dir[ 'test/**/*' ]
  s.require_paths = [ 'lib' ]
end
