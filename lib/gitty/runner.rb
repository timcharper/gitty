class Gitty::Runner
  attr_reader :stdin, :stdout
  attr_reader :options
  
  def initialize(args, stdin = STDIN, stdout = STDOUT)
    @args, @stdin, @stdout = args, stdin, stdout
    @options = options[:]
  end
  
  def run
    raise NotImplementedError
  end
  
  protected
end