require 'fileutils'
class Gitty::Hook::Init < Gitty::Runner
  CLIENT_HOOKS = %w[
    applypatch-msg
    pre-applypatch
    post-applypatch
    pre-commit
    prepare-commit-msg
    commit-msg
    post-commit
    pre-rebase
    post-checkout
    post-merge
    pre-auto-gc
  ]
  def run
    puts "Initializing with gitty"
    FileUtils.mkdir_p(".git/hooks/shared")
    FileUtils.mkdir_p(".git/hooks/local")

    CLIENT_HOOKS.each do |hook|
      FileUtils.cp((HOOK_PATH + "hookd_wrapper").to_s, ".git/hooks/#{hook}")
      FileUtils.chmod(755, ".git/hooks/#{hook}")
    end
  end
  
  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook init"
    end
  end
end
