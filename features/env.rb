require File.dirname(__FILE__) + "/../lib/gitty"
require 'rubygems'
require 'cucumber'

Gitty::Hook.new(ARGV).run
