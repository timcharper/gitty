require GITTY_PATH + "commands/manager"

class Gitty::HookCommand::Add < Gitty::HookCommand::Manager
  include FileUtils

  def run
    hook = Gitty::Hook.find(@hookname, :kind => :available)
    hook.install(options[:kind])
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook add [opts] hook-name"
    end
  end
end
