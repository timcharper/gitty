class Gitty::Hook::Init < Gitty::Runner
  def run
  end
  
  def option_parser(options)
    OptionParser.new do |opts|
      opts.banner = "Usage: git hook init"
      opts.separator "Options:"
    end
  end
  
  def parse_args!(args)
    opt_p = option_parser
    opt_p.banner = banner
    opt_p.parse!(args)
  end
end
