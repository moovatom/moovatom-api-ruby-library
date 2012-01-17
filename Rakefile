require 'bundler/gem_tasks'
require "bundler/version"
require 'rake/testtask'

desc "Run specs"
task :default => :minitest

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/*_spec.rb']
end
 
desc "Build gem"
task :build do
  system "gem build moovatom.gemspec"
end
 
desc "Release gem"
task :release => :build do
  system "gem push pkg/moovatom-#{MoovAtom::VERSION}.gem"
end
