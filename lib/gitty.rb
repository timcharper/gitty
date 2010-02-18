require "pathname"
GITTY_LIB_PATH = Pathname.new(File.dirname(__FILE__))
HOOK_PATH = GITTY_LIB_PATH + "../hooks"
GITTY_PATH = GITTY_LIB_PATH + "gitty"
$: << GITTY_LIB_PATH.to_s

module Gitty
end

require "string.rb"
require "ext.rb"
require "gitty/runner.rb"
require "gitty/hook.rb"
