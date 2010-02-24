require "pathname"

GITTY_ROOT_PATH = Pathname.new(File.expand_path("..", File.dirname(__FILE__)))
ASSETS_PATH    = GITTY_ROOT_PATH + "assets"
GITTY_LIB_PATH = GITTY_ROOT_PATH + "lib"
GITTY_PATH     = GITTY_ROOT_PATH + "lib/gitty"
$: << GITTY_LIB_PATH.to_s

require 'fileutils'
require 'stringio'
require 'yaml'
require "string.rb"
require "ext.rb"

module Gitty
  autoload :Helpers, (GITTY_PATH + "helpers.rb").to_s
  def self.asset_paths
    [ENV["GITTY_ASSETS"], ENV["HOME"] + "/.gitty", ASSETS_PATH].compact.map {|p| Pathname.new(p)}
  end

  def self.find_asset(file)
    asset_paths.each do |asset_path|
      fullpath = File.join(asset_path, file)
      return fullpath if File.exist?(fullpath)
    end
    nil
  end
end

require "gitty/runner.rb"
require "gitty/hook.rb"
require "gitty/hook_command.rb"
