require GITTY_PATH + "commands/manager"

class Gitty::Hook::Add < Gitty::Hook::Manager
  def run
    meta_data["targets"].each do |target|
      FileUtils.cp(asset_file, target_file(target))
      FileUtils.chmod(0755, target_file(target))
    end
    meta_data["helpers"].each do |helper|
      FileUtils.cp(Gitty.find_asset("helpers/#{helper}"), helpers_directory + helper)
      FileUtils.chmod(0755, helpers_directory + helper)
    end
  end
end
