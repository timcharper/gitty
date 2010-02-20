module Gitty::Helpers
  def existing_directory!(dir)
    FileUtils.mkdir_p(dir)
    Pathname.new(dir)
  end

  def file_with_existing_directory!(path)
    FileUtils.mkdir_p(File.dirname(path))
    Pathname.new(path)
  end
  
  def with_env_var(name, value, &block)
    previous_value, ENV[name] = ENV[name], value
    yield
    ENV[name] = previous_value
  end
  
  def cmd(*args)
    system(*args.flatten)
  end
end