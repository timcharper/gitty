require GITTY_PATH + "commands/manager"
class Gitty::Hook::Remove < Gitty::Hook::Manager
  include FileUtils
  def run
    rm(master_hook_file)
    meta_data["targets"].each do |target|
      rm(target_file(target))
    end
    # TODO - cleanup helpers
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook remove [opts] hook-name"
    end
  end
end
