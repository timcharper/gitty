class Gitty::Hook < Gitty::Runner
  COMMANDS = %w[
    init
    add
    remove
    publish
    shell
  ]
  COMMANDS.each do |cmd|
    autoload cmd.classify.to_sym, (GITTY_PATH + "commands/#{cmd}.rb").to_s
  end
  
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    @args, @stdout, @stderr = args, stdout, stderr
    if COMMANDS.include?(args.first)
      @target = Gitty::Hook.const_get(args.shift.classify).new(args, stdout, stderr)
    else
      parse_args!
    end
  end
  
  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook [command]\nCommands are: #{COMMANDS.join(', ')}"
    end
  end

  def run
    unless File.directory?(".git")
      stderr.puts "You must run git hook from the root of a git repository"
      exit 1
    end
    @target && @target.run
  end

  def parse_args!
    opt_p = option_parser
    opt_p.parse!(args)
    puts opt_p
  end
end
