class Gitty::HookCommand::Uninstall < Gitty::Runner
  include FileUtils
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def run
    options = {:installed => true}
    options[:install_kind] = options[:kind] if options[:kind]
    hook = Gitty::Hook.find(@hookname, options)
    return no_hook_found unless hook
    hook.uninstall

    stdout.puts "#{hook.install_kind} hook #{hook.name} has been successfully uninstalled."
    if hook.install_kind == :shared
      stdout.puts "To propagate this change other developers, run 'git hook publish -m \"removed #{hook.name}\""
    end
  end

  protected

  def no_hook_found
    stderr.puts("there is no installed hook named '#{@hookname}'")
    exit 1
  end

  def options
    @options ||= super.update(:kind => :local)
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook uninstall [opts] hook-name"
      opts.on("-l", "--local", "Local hook (default)") { |l| options[:kind] = :local }
      opts.on("-s", "--shared", "Remote hook") { |l| options[:kind] = :shared }
    end
  end
end
