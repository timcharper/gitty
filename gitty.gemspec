Gem::Specification.new do |s|
  s.name = 'gitty'
  s.version = File.read('VERSION').chomp

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Tim Harper']
  s.date = Date.today
  s.description = "Unobtrusively extend git"
  s.email = "timcharper@gmail.com"
  s.executables = ["git-hook"]
  s.extra_rdoc_files = ["LICENSE", "README.textile"]
  s.files = Dir['lib/**/*.rb'] + Dir['assets/**/*'] + ['bin/git-hook'] + Dir['cucumber/**/*'] + Dir['spec/**/*'] + %w[cucumber.yml Rakefile README.textile LICENSE]
  s.homepage = 'http://github.com/timcharper/gitty'
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.7"
  s.summary = 'Unobtrusively extend git'
  s.test_files = Dir['spec/**/*.rb']
end

