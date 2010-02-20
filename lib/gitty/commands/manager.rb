class Gitty::Hook::Manager < Gitty::Runner
  include ::Gitty::Helpers
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def options
    @options ||= super.update(:kind => :local)
  end

  def asset_file
    Gitty.find_asset("hooks/#{@hookname}")
  end

  def meta_data
    @meta_data ||= Gitty.extract_meta_data(File.read(asset_file))
  end

  def run
    raise NotImplementedError
  end

  def target_file(hook)
    @target_file ||= file_with_existing_directory!(base_directory + "#{hook}.d/#{@hookname}")
  end

  def base_directory
    @base_directory ||= existing_directory!(".git/hooks/#{options[:kind]}")
  end

  def helpers_directory
    @helpers_directory ||= existing_directory!(".git/hooks/#{options[:kind]}/helpers")
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook add [opts] hook-name"
      opts.on("-l", "--local", "Local hook (default)") { |l| options[:kind] = :local }
      opts.on("-s", "--shared", "Remote hook") { |l| options[:kind] = :shared }
    end
  end

end