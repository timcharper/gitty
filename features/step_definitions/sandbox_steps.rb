require 'tempfile'
class SandboxWorld
  GITTY_BIN   = File.expand_path("../../bin/git-hook", File.dirname(__FILE__))
  RUBY_BINARY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  TMP_PATH    = Pathname.new(File.expand_path("../../tmp", File.dirname(__FILE__)))
  GITTY_ASSETS= TMP_PATH + "assets"
  SANDBOX_PATH= TMP_PATH + "sandbox"
  REMOTES_PATH= TMP_PATH + "remotes"

  def initialize
    @current_dir = SANDBOX_PATH
  end

  private
  attr_reader :last_exit_status, :last_stderr, :last_stdout
  def last_stderr
    return @last_stderr if @last_stderr
    if @background_job
      @last_stderr = @background_job.stderr.read
    end
  end


  def last_stdout
    return @last_stdout if @last_stdout
    if @background_job
      @last_stdout = @background_job.stdout.read
    end
  end

  def create_file(file_name, file_content)
    file_content.gsub!("SPORK_LIB", "'#{spork_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def in_dir(new_dir, &block)
    @current_dir, last_dir = new_dir, @current_dir
    in_current_dir(&block)
    @current_dir = last_dir
  end

  def localized_command(command)
    command, args = command.scan(/^(git-hook|git hook|\w+)\s*(.*)$/).flatten
    case command
    when 'git-hook', 'git hook'
      command = SandboxWorld::GITTY_BIN
      "#{SandboxWorld::RUBY_BINARY} #{command} #{args}"
    else
      [command, args].join(" ")
    end
  end

  def run(command)
    command = localized_command(command)
    puts command
    stderr_file = Tempfile.new('gitty')
    stderr_file.close
    in_current_dir do
      @last_stdout = `#{command} 2> #{stderr_file.path}`
      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
    if $verbose
      puts @last_stderr
      puts @last_stdout
    end
    @last_stdout
  end

  def interpolate_env_vars!(string)
    ENV.each do |key, value|
      string.gsub!("$#{key}", value)
    end
    string
  end
end

World do
  SandboxWorld.new
end

Before do
  FileUtils.rm_rf SandboxWorld::TMP_PATH
  FileUtils.mkdir_p SandboxWorld::SANDBOX_PATH
  ENV["GITTY_ASSETS"] = GITTY_ASSETS.to_s
  ENV['REMOTES_PATH'] = REMOTES_PATH.to_s
end


Given /^I am in the directory "(.*)"$/ do |path|
  path = (SandboxWorld::SANDBOX_PATH + path).to_s
  FileUtils.mkdir_p(path)
  @current_dir = File.join(path)
end

Given /^I switch back to the original repository$/ do
  @current_dir = SandboxWorld::SANDBOX_PATH.to_s
end

Given /^a file named "([^\"]*)"$/ do |file_name|
  create_file(file_name, '')
end

Given /^a file named "([^\"]*)" with:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

When /^the contents of "([^\"]*)" are changed to:$/ do |file_name, file_content|
  create_file(file_name, file_content)
end

# the following code appears in "config/environment.rb" after /Rails::Initializer.run/:
Given /^the following code appears in "([^\"]*)" after \/([^\\\/]*)\/:$/ do |file_name, regex, content|
  regex = Regexp.new(regex)
  in_current_dir do
    content_lines = File.read(file_name).split("\n")
    0.upto(content_lines.length - 1) do |line_index|
      if regex.match(content_lines[line_index])
        content_lines.insert(line_index + 1, content)
        break
      end
    end
    File.open(file_name, 'wb') { |f| f << (content_lines * "\n") }
  end
end

When /^I run "(.+)"$/ do |command|
  run(command)
end

Then /^the file "([^\"]*)" should include "([^\"]*)"$/ do |filename, content|
  in_current_dir do
    File.read(filename).should include(content)
  end
end

Then /^the following (files|folders) should exist:$/ do |file_or_dir, table|
  in_current_dir do
    table.raw.map { |r| r.first}.each do |path|
      next if File.exist?(path)
      raise Spec::Expectations::ExpectationNotMetError, "expected #{path} to exist, but it didn't."
    end
  end
end

Then /^the following (files|folders) should not exist:$/ do |file_or_dir, table|
  in_current_dir do
    table.raw.map.each do |path|
      File.exist?(path.first).should == false
    end
  end
end

Then /^the (error output|output) should contain$/ do |which, text|
  (which == "error output" ? last_stderr : last_stdout).should include(text)
end

Then /^the (error output|output) should contain "(.+)"$/ do |which, text|
  (which == "error output" ? last_stderr : last_stdout).should include(text)
end

Then /^the (error output|output) should match \/(.+)\/$/ do |which, regex|
  (which == "error output" ? last_stderr : last_stdout).should match(Regexp.new(regex))
end

Then /^the (error output|output) should not contain$/ do |which, text|
  (which == "error output" ? last_stderr : last_stdout).should_not include(text)
end

Then /^the (error output|output) should not contain "(.+)"$/ do |which, text|
  (which == "error output" ? last_stderr : last_stdout).should_not include(text)
end

Then /^the (error output|output) should be empty$/ do |which|
  (which == "error output" ? last_stderr : last_stdout).should == ""
end

Then /^the (error output|output) should be$/ do |which, text|
  (which == "error output" ? last_stderr : last_stdout).should == text
end

