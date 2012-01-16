require 'bundler/gem_tasks'
require 'rake/testtask'

task :default => :minitest

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/*_spec.rb']
end

