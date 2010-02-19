class Gitty::Hook::Publish < Gitty::Runner
  def run
    rev = nil
    puts "Publishing with message #{options[:message].inspect}"
    with_env_var("GIT_OBJECT_DIRECTORY", File.join(Dir.pwd, ".git/objects")) do
      Dir.chdir(".git/hooks/shared") do
        if File.exist?(".git")
          # ...
        else
          cmd(*%w[git init])
          cmd(*%w[git symbolic-ref HEAD refs/heads/--hooks--])
          cmd(*%w[git commit --allow-empty -m initial\ commit])
        end
        cmd(*%w[git add . -A])
        cmd(*%w[git commit -m].push(options[:message]))
        rev = %x{git rev-parse HEAD}.chomp
      end
    end
    # back on the mother repo...
    cmd(*%w[git push origin].push("#{rev}:refs/heads/--hooks--"))
  end

  protected
    def with_env_var(name, value, &block)
      previous_value, ENV[name] = ENV[name], value
      yield
      ENV[name] = previous_value
    end

    def option_parser
      @option_parser ||= super.tap do |opts|
        opts.banner = "Usage: git hook publish [options]"
        opts.on("-m [message]", "--message [message]", "Message for commit (required)") do |m|
          options[:message] = m
        end
      end
    end

    def cmd(*args)
      system(*args.flatten)
    end

    def parse_args!
      super
      if options[:message].nil?
        puts option_parser
      end
    end
end
