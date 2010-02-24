
World do
  SandboxWorld.new
end

Before do
  reset_sandbox!
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

