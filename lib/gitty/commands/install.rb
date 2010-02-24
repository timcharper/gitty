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

    hook.install(options[:kind])
    if options[:kind] == :shared
      stdout.puts "To propagate this change other developers, run 'git hook publish -m \"added #{hook.name}...\""
    end
  end

  def options
    @options ||= super.update(:kind => :local)
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook install [opts] hook-name"
      opts.on("-l", "--local", "Local hook (default)") { |l| options[:kind] = :local }
      opts.on("-s", "--shared", "Remote hook") { |l| options[:kind] = :shared }
    end
  end
end
