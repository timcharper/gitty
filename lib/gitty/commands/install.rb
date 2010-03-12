class Gitty::HookCommand::Install < Gitty::Runner
  include FileUtils
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def run
    hook = Gitty::Hook.find(@hookname, :installed => false)
    if hook.nil?
      stderr.puts "no hook named '#{@hookname}' found."
      exit 1
    end
    hook.install(:local)
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook install [opts] hook-name"
    end
  end
end
