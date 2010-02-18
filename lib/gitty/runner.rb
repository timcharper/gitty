require "optparse"
class Gitty::Runner
  attr_reader :stdin, :stdout, :args
  attr_reader :options
  
  def initialize(args, stdin = STDIN, stdout = STDOUT)
    @args, @stdin, @stdout = args, stdin, stdout
    @options = {}
    parse_args!
  end
  
  def run
    raise NotImplementedError
  end
  
  def option_parser
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0}"
      opts.separator "Options:"
      opts.on('--help', "Show help")
    end
  end

  protected
    def parse_args!
      option_parser.parse!(args)
    end
end