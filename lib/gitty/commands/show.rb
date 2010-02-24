class Gitty::HookCommand::Show < Gitty::Runner
  def initialize(args, stdout = STDOUT, stderr = STDERR)
    super
    @hookname = args.shift
  end

  def run
    hook = Gitty::Hook.find(@hookname)
    unless hook
      stderr.puts "Hook '#{@hookname}' not found"
      exit 1
    end
    stdout << "Hook '#{hook.name}' is " + (hook.installed? ? 'installed' : 'not installed' ) + "\n\n"
    stdout << "DESCRIPTION:\n" + (hook.meta_data['description'] || "no description") + "\n\n"
    stdout.puts "version: #{hook.meta_data['version']}" if hook.meta_data['version']
    stdout.puts "targets: #{hook.meta_data['targets'].join(', ')}" if hook.meta_data['targets']
  end

  def option_parser
    @option_parser ||= super.tap do |opts|
      opts.banner = "Usage: git hook show hook-name"
    end
  end
end
