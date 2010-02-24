class Gitty::HookCommand::Remove < Gitty::Runner
  include FileUtils
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def run
    hook = Gitty::Hook.find(@hookname, :install_kind => options[:kind])
    hook.uninstall
  end

  def options
    @options ||= super.update(:kind => :local)
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook remove [opts] hook-name"
      opts.on("-l", "--local", "Local hook (default)") { |l| options[:kind] = :local }
      opts.on("-s", "--shared", "Remote hook") { |l| options[:kind] = :shared }
    end
  end
end
