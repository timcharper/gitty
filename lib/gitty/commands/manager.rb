class Gitty::HookCommand::Manager < Gitty::Runner
  include ::Gitty::Helpers
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def options
    @options ||= super.update(:kind => :local)
  end

  def run
    raise NotImplementedError
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.on("-l", "--local", "Local hook (default)") { |l| options[:kind] = :local }
      opts.on("-s", "--shared", "Remote hook") { |l| options[:kind] = :shared }
    end
  end
end