require File.dirname(__FILE__) + "/../lib/gitty"
require 'rubygems'
require "rspec"
SPEC_PATH = Pathname.new(File.dirname(__FILE__))
require SPEC_PATH + "../features/support/sandbox_world.rb"
require SPEC_PATH + "support/constants.rb"


require 'forwardable'
RSpec.configure do |config|
  extend Forwardable
  def sandbox
    @sandbox ||= SandboxWorld.new
  end

  [:run, :in_dir, :current_dir, :create_file, :last_exit_status, :last_stderr, :last_stdout, :reset_sandbox!].each do |m|
    eval "def #{m}(*args) sandbox.send(:#{m}, *args) end"
  end

  config.before(:each) do
    @_original_dir = Dir.pwd
    reset_sandbox!
    Dir.chdir(current_dir)
  end

  config.after(:each) do
    Dir.chdir(@_original_dir)
  end
end
