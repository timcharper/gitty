require 'fileutils'
class Gitty::Hook::Shell < Gitty::Runner
  include ::Gitty::Helpers

  def run
    exec "bash --init-file #{create_init_file}"
  end

  def create_init_file
    "/tmp/gitty-shell-init".tap do |filename|
      File.open(filename, "wb") do |f|
        f.puts(<<-EOF)
        pushd $HOME > /dev/null
          [ -f $HOME/.bashrc ] && . $HOME/.bashrc
          [ -f $HOME/.bash_profile ] && . $HOME/.bash_profile
        popd > /dev/null
        export GIT_OBJECT_DIRECTORY="$(pwd)/.git/objects"

        export PS1="Shared Hooks [$(basename $(pwd))]$ "
        cd .git/hooks/shared
        rm "#{filename}"
        EOF
      end
    end
  end

  def option_parser
    super.tap do |opts|
      opts.banner = "Usage: git hook shell"
    end
  end
end
