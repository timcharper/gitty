Given /^the file "(.+)" contains:$/ do |filename, content|
  filename.gsub!("$GITTY_ASSETS", ENV["GITTY_ASSETS"])
  FileUtils.mkdir_p(File.dirname(filename))
  File.open(filename, "wb") { |f| f << content }
end
