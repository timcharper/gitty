class Gitty::HookCommand::Publish < Gitty::Runner
  include ::Gitty::Helpers
  
  def run
    rev = nil
    puts "Publishing with message #{options[:message].inspect}"
    with_env_var("GIT_OBJECT_DIRECTORY", File.join(Dir.pwd, ".git/objects")) do
      Dir.chdir(".git/hooks/shared") do
        cmd(*%w[git add . -A])
        cmd(*%w[git commit -m].push(options[:message]))
        rev = %x{git rev-parse HEAD}.chomp
      end
    end
    # back on the mother repo...
    cmd(*%w[git push origin -f].push("#{rev}:refs/heads/--hooks--"))
  end

  protected
    def option_parser
      @option_parser ||= super.tap do |opts|
        opts.banner = "Usage: git hook publish [options]"
        opts.on("-m [message]", "--message [message]", "Message for commit (required)") do |m|
          options[:message] = m
        end
      end
    end

    def parse_args!
      super
      if options[:message].nil?
        puts option_parser
        puts "A message is required"
        exit 1
      end
    end
end
