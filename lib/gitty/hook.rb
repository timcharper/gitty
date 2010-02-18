class Gitty::Hook < Gitty::Runner
  COMMANDS = %w[
    init
  ]
  COMMANDS.each do |cmd|
    autoload cmd.classify.to_sym, (GITTY_PATH + "commands/#{cmd}.rb").to_s
  end
  
  def initialize(args, stdin = STDIN, stdout = STDOUT)
    @args, @stdin, @stdout = args, stdin, stdout
    if COMMANDS.include?(args.first)
      @target = Gitty::Hook.const_get(args.first.classify).new(args, stdin, stdout)
    else
      parse_args!
    end
  end
  
  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook [command]\nCommands are: #{COMMANDS.join(', ')}"
    end
  end

  def run
    @target && @target.run
  end

  def parse_args!
    opt_p = option_parser
    opt_p.banner = banner
    opt_p.parse!(args)
    pp args
  end
end
