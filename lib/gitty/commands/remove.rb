require GITTY_PATH + "commands/manager"
class Gitty::Hook::Remove < Gitty::Hook::Manager
  def run
    meta_data["targets"].each do |target|
      FileUtils.rm(target_file(target))
    end
    # TODO - cleanup helpers
  end
end
