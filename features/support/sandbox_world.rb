require 'tempfile'
class SandboxWorld
  GITTY_BIN   = File.expand_path("../../bin/git-hook", File.dirname(__FILE__))
  RUBY_BINARY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  TMP_PATH    = Pathname.new(File.expand_path("../../tmp", File.dirname(__FILE__)))
  GITTY_ASSETS= TMP_PATH + "assets"
  SANDBOX_PATH= TMP_PATH + "sandbox"
  REMOTES_PATH= TMP_PATH + "remotes"

  def initialize
    @current_dir = SANDBOX_PATH
  end

  private
  attr_reader :last_exit_status, :last_stderr, :last_stdout, :current_dir

  def create_file(file_name, file_content)
    in_current_dir do
      FileUtils.mkdir_p(File.dirname(file_name))
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def in_dir(new_dir, &block)
    @current_dir, last_dir = new_dir, @current_dir
    in_current_dir(&block)
    @current_dir = last_dir
  end

  def localized_command(command)
    command, args = command.scan(/^(git-hook|git hook|\w+)\s*(.*)$/).flatten
    case command
    when 'git-hook', 'git hook'
      command = SandboxWorld::GITTY_BIN
      "#{SandboxWorld::RUBY_BINARY} #{command} #{args}"
    else
      [command, args].join(" ")
    end
  end

  def run(command)
    command = localized_command(command)
    puts command
    stderr_file = Tempfile.new('gitty')
    stderr_file.close
    in_current_dir do
      @last_stdout = `#{command} 2> #{stderr_file.path}`
      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
    if $verbose
      puts @last_stderr
      puts @last_stdout
    end
    @last_stdout
  end

  def interpolate_env_vars!(string)
    ENV.each do |key, value|
      string.gsub!("$#{key}", value)
    end
    string
  end

  def reset_sandbox!
    @current_dir = SANDBOX_PATH
    FileUtils.rm_rf SandboxWorld::TMP_PATH
    FileUtils.mkdir_p SandboxWorld::SANDBOX_PATH
    ENV["GITTY_ASSETS"] = GITTY_ASSETS.to_s
    ENV['REMOTES_PATH'] = REMOTES_PATH.to_s
  end
end
