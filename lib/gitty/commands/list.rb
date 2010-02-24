require 'fileutils'
class Gitty::HookCommand::List < Gitty::Runner
  include ::Gitty::Helpers
  include FileUtils
  KINDS = [:local, :shared, :uninstalled]

  def run
    stdout.puts "Listing hooks"
    which_to_show = KINDS.select { |k| options[k] }
    which_to_show = KINDS if which_to_show.empty? # default to everything
    which_to_show.each { |w| show_hooks(w) }
  end

  def all_hooks
    @all_hooks = Gitty::Hook.find_all
  end

  def show_hooks(which)
    case which
    when :local, :shared then show_local_or_shared_hooks(which)
    when :uninstalled then show_uninstalled_hooks
    end
  end

  def show_local_or_shared_hooks(which)
    hook_names = all_hooks.select { |h| h.install_kind == which.to_sym }.map(&:name)
    puts "#{which}:\n#{listify(hook_names)}\n\n"
  end

  def listify(hooks)
    hooks.map { |h| "- #{h}" }.join("\n")
  end

  def show_uninstalled_hooks
    available_hook_names = all_hooks.select { |h| ! h.installed? }.map(&:name)
    installed_hook_names = all_hooks.select { |h| h.installed? }.map(&:name)
    uninstalled_hooks = (available_hook_names - installed_hook_names).sort
    puts "uninstalled:\n#{listify(uninstalled_hooks)}\n\n"
  end

  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook list"
      opts.on("-l", "--local", "Show local hooks") do
        options[:local] = true
      end
      opts.on("-s", "--shared", "Show shared hooks") do
        options[:shared] = true
      end
      opts.on("-u", "--uninstalled", "Show uninstalled hooks") do
        options[:uninstalled] = true
      end
    end
  end
end
