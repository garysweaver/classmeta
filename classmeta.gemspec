# -*- encoding: utf-8 -*-  
$:.push File.expand_path("../lib", __FILE__)  
require "classmeta/version" 

Gem::Specification.new do |s|
  s.name        = 'classmeta'
  s.version     = Classmeta::VERSION
  s.authors     = ['Gary S. Weaver']
  s.email       = ['garysweaver@gmail.com']
  s.homepage    = 'https://github.com/garysweaver/activerecord-refs'
  s.summary     = %q{Magic class creation.}
  s.description = 'Magic class creator that lets you create and transform classes dynamically.'
  s.files = Dir['lib/**/*'] + ['Rakefile', 'README.md']
  s.license = 'MIT'
end
