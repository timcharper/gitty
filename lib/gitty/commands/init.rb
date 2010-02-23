require 'fileutils'
class Gitty::HookCommand::Init < Gitty::Runner
  include ::Gitty::Helpers
  
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
    FileUtils.mkdir_p(".git/hooks/shared")
    FileUtils.mkdir_p(".git/hooks/local")

    CLIENT_HOOKS.each do |hook|
      FileUtils.cp((ASSETS_PATH + "helpers/hookd_wrapper").to_s, ".git/hooks/#{hook}")
      FileUtils.chmod(0755, ".git/hooks/#{hook}")
    end
    
    hooks_rev = remote_hooks_rev
    
    with_env_var("GIT_OBJECT_DIRECTORY", File.join(Dir.pwd, ".git/objects")) do
      Dir.chdir(".git/hooks/shared") do
        unless File.exist?(".git")
          cmd(*%w[git init])
          cmd(*%w[git symbolic-ref HEAD refs/heads/--hooks--])
          cmd(*%w[git commit --allow-empty -m initial\ commit])
        end
        cmd(*%w[git reset --hard], hooks_rev) if hooks_rev
      end
    end
  end
  
  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook init"
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
