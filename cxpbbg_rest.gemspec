# -*- encoding: utf-8 -*-
dirname = File.basename(Dir.getwd)
lib = File.expand_path("../../#{dirname}/lib/", __FILE__)

$:.unshift(lib) unless $:.include?(lib)

require 'cxpbbg_rest/version'

Gem::Specification.new do |s|
  s.name        = "cxpbbg_rest"
  s.version     = CxpbbgRest::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Liwen Liu', 'Eric Pugh']
  s.email       = ["lliu@metrostarsystems.com","epugh@bbg.gov"]
  s.homepage = 'http://github.com/outoftime/cxpbbg_rest/tree/master/cxpbbg_rest'
  s.summary     = 'Rails integration for publishing to BBG Content Exchage Platform'
  s.license     = 'MIT'
  s.description = <<-TEXT
    CxpbbgRest is an extension to post to BBG Content Exchage platform
  TEXT

  s.rubyforge_project = "cxpbbg_rest"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '~> 4'
  # s.add_development_dependency 'rspec', '~> 1.2'
  # s.add_development_dependency 'rspec-rails', '~> 1.2'

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake", '~> 10.4'
  
  s.rdoc_options << '--webcvs=http://github.com/outoftime/cxpbbg_rest/tree/master/%s' <<
                  '--title' << 'Bbg-Cxp - Rails integration for the BBG Content Exchage Platform library - API Documentation' <<
                  '--main' << 'README.rdoc'
end
