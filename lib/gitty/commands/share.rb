class Gitty::HookCommand::Share < Gitty::Runner
  include FileUtils
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def run
    hook = Gitty::Hook.find(@hookname, :install_kind => :local) || Gitty::Hook.find(@hookname, :installed => false)
    if hook.nil?
      stderr.puts "no hook named '#{@hookname}' is available"
      exit 1
    end
    if hook.install_kind == :shared
      stderr.puts "hook #{@hookname} is already installed"
      exit 1
    end
    unless Gitty.sharing_enabled?
      stderr.puts "WARNING: sharing is disabled on your repository.  Run git hook init --enable-sharing to turn it on."
    end
    hook.share!
    stdout.puts "To propagate this change other developers, run 'git hook publish -m \"added #{hook.name}...\""
  end

  def options
    @options ||= super.update(:kind => :local)
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook install [opts] hook-name"
    end
  end
end
