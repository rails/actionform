# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'action_form/version'

Gem::Specification.new do |s|
  s.name        = 'actionform'
  s.version     = ActionForm::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Petros Markou']
  s.email       = ['markoupetr@gmail.com']
  s.homepage    = 'https://github.com/jbox-web/actionform'
  s.summary     = 'Create nested forms with ease.'
  s.description = 'An alternative layer to accepts_nested_attributes_for by using Form Models.'
  s.license     = 'MIT'

  s.add_dependency 'rails', '>= 4.2'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'appraisal'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
