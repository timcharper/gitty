require GITTY_PATH + "commands/manager"
class Gitty::HookCommand::Remove < Gitty::HookCommand::Manager
  include FileUtils
  def run
    hook = Gitty::Hook.find(@hookname, :install_kind => options[:kind])
    hook.uninstall
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook remove [opts] hook-name"
    end
  end
end
