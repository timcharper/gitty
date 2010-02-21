require GITTY_PATH + "commands/manager"

class Gitty::Hook::Add < Gitty::Hook::Manager
  include FileUtils

  def run
    cp(src_hook_file, master_hook_file)
    chmod(0755, master_hook_file)
    meta_data["targets"].each do |target|
      ln_s(
        "../hooks/#{@hookname}",
        file_with_existing_directory!(base_directory + "#{target}.d" + @hookname)
      )
    end
    meta_data["helpers"].each do |helper|
      cp(Gitty.find_asset("helpers/#{helper}"), helpers_directory + helper)
      chmod(0755, helpers_directory + helper)
    end
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook add [opts] hook-name"
    end
  end
end
