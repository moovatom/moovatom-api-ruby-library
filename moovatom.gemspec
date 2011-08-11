# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "moovatom/version"

Gem::Specification.new do |s|
  s.name        = "moovatom"
  s.version     = Moovatom::VERSION
  s.authors     = ["Dominic Giglio"]
  s.email       = ["humanshell@gmail.com"]
  s.homepage    = "http://moovatom.com"
  s.summary     = %q{Access MoovAtom API}
  s.description = %q{This gem defines methods for controlling your videos on MoovAtom using the MoovEngine API.}

  s.rubyforge_project = "moovatom"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
