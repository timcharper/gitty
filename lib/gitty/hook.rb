class Gitty::Hook < Gitty::Runner
  COMMANDS = %w[
    init
  ]
  COMMANDS.each do |cmd|
    autoload cmd.classify.to_sym, GITTY_PATH + "commands/#{cmd}.rb"
  end
  
  def option_parser(options)
    OptionParser.new do |opts|
      opts.banner = "Usage: git hook [command] #{$0} seller email buyer1,buyer2,... [options]"
      opts.separator "Options:"
    end
  end
  
  def parse_args!(args)
    opt_p = option_parser
    opt_p.banner = banner
    opt_p.parse!(args)
  end
end
