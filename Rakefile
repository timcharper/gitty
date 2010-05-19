require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "gitty"
    gem.summary = %Q{Unobtrusively extend git}
    gem.description = %Q{Unobtrusively extend git}
    gem.email = "timcharper@gmail.com"
    gem.homepage = "http://github.com/timcharper/gitty"
    gem.authors = ["Tim Harper"]
    gem.files = Dir['lib/**/*.rb'] + Dir['assets/**/*'] + ['bin/git-hook'] + Dir['cucumber/**/*'] + Dir['spec/**/*'] + %w[cucumber.yml Rakefile README.textile LICENSE]
    # gem.executables << 'git-hook'/
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gitty #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
