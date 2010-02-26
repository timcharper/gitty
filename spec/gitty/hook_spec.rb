require File.expand_path('../../spec_helper', __FILE__)

describe Gitty::Hook do
  def installed_hook(name, which = :local)
    hook = Gitty::Hook.find(name, :installed => false)
    hook.install(which)
    Gitty::Hook.find(name, :installed => true)
  end

  before(:each) do
    Gitty::Hook.stub!(:available_hooks_search_paths).and_return([SandboxWorld::GITTY_ASSETS + "hooks"])
    create_file(SandboxWorld::GITTY_ASSETS + "hooks/submodule_updater", <<-EOF)
#!/bin/bash
# description: managers submodule updating for you
# targets: ["post-checkout", "post-merge"]
...
EOF
    create_file(SandboxWorld::GITTY_ASSETS + "hooks/no_messy_whitespace", <<-EOF)
#!/bin/bash
# description: prevents you from committing messy whitespace
# targets: ["pre-commit"]
...
EOF
  end

  describe ".extract_meta_data" do
    it "extracts meta data from a stream" do
      stream = <<-EOF
#!/usr/bash

# description: |-
#   hi
#
#   bye
# targets: ["post-merge", "post-checkout"]
#

here's my hook
EOF
      Gitty::Hook.extract_meta_data(stream).should == {
        "description" => "hi\n\nbye",
        "targets" => ["post-merge", "post-checkout"]
      }
    end

    it "returns nil when no data found" do
      stream = <<-EOF
#!/usr/bash
#
#
EOF
      Gitty::Hook.extract_meta_data(stream).should == nil
    end

    it "returns the data when there's no actual content" do
      stream = <<-EOF
#!/usr/bash
#
# description: hi
EOF
      Gitty::Hook.extract_meta_data(stream).should == {"description" => "hi"}
    end
  end
  describe ".find_all" do
    it "returns all available hooks" do
      Gitty::Hook.find_all(:installed => false).map(&:name).should == %w[no_messy_whitespace submodule_updater]
    end
  end

  describe ".find" do
    it "returns an available hook by name" do
      Gitty::Hook.find("submodule_updater", :installed => false).name.should == "submodule_updater"
      Gitty::Hook.find("no_messy_whitespace", :installed => false).name.should == "no_messy_whitespace"
    end

    it "finds installed hooks" do
    end
  end

  describe "#installed?" do
    it "returns false if the hook is not installed" do
      Gitty::Hook.find("submodule_updater", :installed => false).installed?.should be_false
    end

    it "returns true if the hook is installed" do
      Gitty::Hook.find("submodule_updater", :installed => false).install(:local)
      Gitty::Hook.find("submodule_updater", :installed => true).installed?.should == true
    end
  end

  describe "#install_kind" do
    it "returns :local for local hooks" do
      installed_hook("submodule_updater", :local).install_kind.should == :local
    end

    it "returns :shared for shared hooks" do
      installed_hook("submodule_updater", :shared).install_kind.should == :shared
    end
  end

  describe "#meta_data" do
    it "reads the meta_data of a given file" do
      Gitty::Hook.find("submodule_updater", :installed => false).meta_data
    end
  end

  describe "#install" do
    it "copies an available hook to the install path and links it into the targets" do
      @hook = Gitty::Hook.find("submodule_updater", :installed => false)
      @hook.install
      File.exist?(".git/hooks/local/hooks/submodule_updater").should be_true
      File.executable?(".git/hooks/local/hooks/submodule_updater").should be_true
      File.exist?(".git/hooks/local/post-checkout.d/submodule_updater").should be_true
      File.exist?(".git/hooks/local/post-merge.d/submodule_updater").should be_true
    end

    it "installs a hook into shared" do
      @hook = Gitty::Hook.find("submodule_updater", :installed => false)
      @hook.install(:shared)
      File.exist?(".git/hooks/shared/hooks/submodule_updater").should be_true
      File.executable?(".git/hooks/shared/hooks/submodule_updater").should be_true
      File.exist?(".git/hooks/shared/post-checkout.d/submodule_updater").should be_true
      File.exist?(".git/hooks/shared/post-merge.d/submodule_updater").should be_true
    end
  end

  describe "#uninstall" do
    it "removes a hook from installed path" do
      hook = installed_hook("submodule_updater")
      File.exist?(".git/hooks/local/hooks/submodule_updater").should be_true
      File.symlink?(".git/hooks/local/post-checkout.d/submodule_updater").should be_true
      File.symlink?(".git/hooks/local/post-merge.d/submodule_updater").should be_true
      hook.uninstall
      File.exist?(".git/hooks/local/hooks/submodule_updater").should be_false
      File.symlink?(".git/hooks/local/post-checkout.d/submodule_updater").should be_false
      File.symlink?(".git/hooks/local/post-merge.d/submodule_updater").should be_false
      File.directory?(".git/hooks/local/post-checkout.d").should be_false
      File.directory?(".git/hooks/local/post-merge.d").should be_false
    end
  end
end
