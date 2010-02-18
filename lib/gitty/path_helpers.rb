module Gitty::PathHelpers
  def existing_directory!(dir)
    FileUtils.mkdir_p(dir)
    Pathname.new(dir)
  end

  def file_with_existing_directory!(path)
    FileUtils.mkdir_p(File.dirname(path))
    Pathname.new(path)
  end
end