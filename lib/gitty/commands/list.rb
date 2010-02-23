require 'fileutils'
class Gitty::HookCommand::List < Gitty::Runner
  include ::Gitty::Helpers
  include FileUtils
  KINDS = [:local, :shared, :available]

  def run
    stdout.puts "Listing hooks"
    which_to_show = KINDS.select { |k| options[k] }
    which_to_show = KINDS if which_to_show.empty? # default to everything
    which_to_show.each { |w| show_hooks(w) }
  end

  def show_hooks(which)
    case which
    when :local     then show_local_or_shared_hooks('local')
    when :shared    then show_local_or_shared_hooks('shared')
    when :available then show_available_hooks
    end
  end

  def show_local_or_shared_hooks(which)
    hook_names = filenames_in(installed_hooks_path(which))
    return if hook_names.empty?
    puts "#{which}:\n#{listify(hook_names)}\n\n"
  end

  def listify(hooks)
    hooks.map { |h| "- #{h}" }.join("\n")
  end

  def filenames_in(dir)
    if File.directory?(dir)
      Dir.glob((dir + "*").to_s).sort.map do |path|
        File.basename(path)
      end
    else
      []
    end
  end

  def installed_hooks_path(which)
    Pathname.new(".git/hooks/#{which}/hooks")
  end

  def show_available_hooks
    all_hooks = Gitty.asset_paths.map {|asset_path| filenames_in(asset_path + "hooks")}.flatten
    installed_hooks = [:local, :shared].map { |which| filenames_in(installed_hooks_path(which)) }.flatten
    available_hooks = all_hooks.sort - installed_hooks.sort
    puts "available:\n#{listify(available_hooks)}\n\n"
  end

  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook list"
      opts.on("-l", "--local", "Show local hooks") do
        options[:local] = true
      end
      opts.on("-r", "--shared", "Show shared hooks") do
        options[:shared] = true
      end
      opts.on("-a", "--available", "Show available hooks") do
        options[:available] = true
      end
    end
  end
end
