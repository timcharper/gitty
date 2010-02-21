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
    [ENV["GITTY_ASSETS"], ASSETS_PATH].compact.map {|p| Pathname.new(p)}
  end

  def self.find_asset(file)
    asset_paths.each do |asset_path|
      fullpath = File.join(asset_path, file)
      return fullpath if File.exist?(fullpath)
    end
    nil
  end

  def self.creating_dir_if_nonexistant(dir)
    FileUtils.mkdir_p(dir)
    Pathname.new(dir)
  end

  def self.extract_meta_data(string_or_io)
    io = string_or_io.respond_to?(:readline) ? string_or_io : StringIO.new(string_or_io)
    meta_yaml = ""
    begin
      while line = io.readline
        next unless line.match(/^# (description.+)/)
        meta_yaml = "#{$1}\n"
        break
      end

      while line = io.readline
        break unless line.match(/^# (.+)/)
        meta_yaml << "#{$1}\n"
      end
    rescue EOFError
    end
    meta_yaml.empty? ? nil : YAML.load(meta_yaml)
  end
end

require "gitty/runner.rb"
require "gitty/hook.rb"
