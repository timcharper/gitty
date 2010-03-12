require 'fileutils'
class Gitty::HookCommand::Init < Gitty::Runner
  include ::Gitty::Helpers
  include FileUtils
  
  CLIENT_HOOKS = %w[
    applypatch-msg
    commit-msg
    post-applypatch
    post-checkout
    post-commit
    post-merge
    pre-applypatch
    pre-auto-gc
    pre-commit
    pre-rebase
    prepare-commit-msg
  ]
  def run
    puts "Initializing with gitty"
    # MESSY!
    mkdir_p(".git/hooks/gitty")
    mkdir_p(".git/hooks/shared")
    mkdir_p(".git/hooks/local")
    cp((ASSETS_PATH + "helpers/hookd_wrapper").to_s, ".git/hooks/gitty/hookd_wrapper")
    chmod(0755, ".git/hooks/gitty/hookd_wrapper")
    if options[:sharing]
      cp((ASSETS_PATH + "helpers/update-shared-hooks").to_s, ".git/hooks/gitty/update-shared-hooks")
      chmod(0755, ".git/hooks/gitty/update-shared-hooks")
    end

    CLIENT_HOOKS.each do |hook|
      if File.exist?(".git/hooks/#{hook}")
        mkdir_p(".git/hooks/local/#{hook}.d")
        mv(".git/hooks/#{hook}", ".git/hooks/local/#{hook}.d/original")
      end
      ln_sf("gitty/hookd_wrapper", ".git/hooks/#{hook}")
    end
    
    hooks_rev = remote_hooks_rev
    
    with_env_var("GIT_OBJECT_DIRECTORY", File.join(Dir.pwd, ".git/objects")) do
      Dir.chdir(".git/hooks/shared") do
        unless File.exist?(".git")
          cmd(*%w[git init])
          cmd(*%w[git symbolic-ref HEAD refs/heads/--hooks--])
          cmd(*%w[git commit --allow-empty -m initial\ commit])
        end
        cmd("git reset --hard #{hooks_rev}") if hooks_rev

      end
    end
  end
  
  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook init"
      opts.on("-s", "--enable-sharing", "Enable sharing") do
        options[:sharing] = true
      end
    end
  end
  
  protected
    def remote_hooks_rev
      %x{git for-each-ref}.chomp.split("\n").map {|l| l.split(/\s+/) }.each do |rev, kind, ref|
        return rev if ref == "refs/remotes/origin/--hooks--"
      end
      nil
    end
end
