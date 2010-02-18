require "optparse"
class Gitty::Runner
  attr_reader :stdout, :stderr, :args
  
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    @args, @stdout, @stderr = args, stdout, stderr
    parse_args!
  end
  
  def options
    @options ||= {}
  end

  def run
    raise NotImplementedError
  end
  
  def option_parser
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0}"
      opts.separator "Options:"
      opts.on('--help', "Show help") do |h|
        @show_help = opts
      end
    end
  end

  def handle_show_help
    if @show_help
      puts @show_help
      exit(1)
    end
  end

  def self.run(args, stdout = STDOUT, stderr = STDERR)
    new(args, stdout, stderr).run
  end

  protected
    def parse_args!
      option_parser.parse!(args)
      handle_show_help
    end
end