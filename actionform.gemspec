$:.push File.expand_path('../lib', __FILE__)

require 'action_form/version'

Gem::Specification.new do |s|
  s.name        = 'actionform'
  s.version     = ActionForm::VERSION
  s.authors     = ['Petros Markou']
  s.email       = ['markoupetr@gmail.com']
  s.homepage    = 'https://github.com/rails/actionform'
  s.summary     = 'Create nested forms with ease.'
  s.description = 'An alternative layer to accepts_nested_attributes_for by using Form Models.'
  s.license     = 'MIT'

  s.files       = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files  = Dir['test/**/*']

  s.add_dependency 'rails', '~> 4.1'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake', '~> 10.3.2'
  s.add_development_dependency 'rubocop'
end
