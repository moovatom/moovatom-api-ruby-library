require 'bundler/gem_tasks'
require "bundler/version"
require 'rake/testtask'

task :default => :minitest

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/*_spec.rb']
end
 
task :build do
  system "gem build moovatom.gemspec"
end
 
task :release => :build do
  system "gem push pkg/moovatom-#{MoovAtom::VERSION}"
end
