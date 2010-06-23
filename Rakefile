require 'rake'
require 'jeweler'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rcov/rcovtask'

Jeweler::Tasks.new do |gem|
  gem.name = "ms-in_silico"
  gem.summary = 'in-silico calculations for mass spec data'
  gem.description = 'peptide fragmentation and protein digestion'
  gem.email = "jtprince@gmail.com"
  gem.homepage = "http://github.com/jtprince/ms-in_silico"
  gem.authors = ["Simon Chiang"]
  gem.rubyforge_project = "mspire"
  gem.add_dependency("molecules", ">= 0.2.0")
  gem.add_dependency("tap", ">= 0.17.0")
  gem.add_development_dependency("tap-test", ">= 0.1.0")
  gem.add_development_dependency("spec-more", ">= 0")
end
Jeweler::GemcutterTasks.new

Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

Rcov::RcovTask.new do |spec|
  spec.libs << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ms-in_silico #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
