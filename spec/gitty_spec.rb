require 'spec_helper'

describe Gitty do
  describe ".asset_file" do
    it "searches first in the specified $GITTY_ASSETS environment variable" do
      ENV.stub!(:[]).with("GITTY_ASSETS").and_return("/tmp/assets")
      File.stub!(:exist?).with("/tmp/assets/helpers/helpful").and_return(true)
      File.stub!(:exist?).with(ASSETS_PATH + "helpers/helpful").and_return(true)

      Gitty.find_asset("helpers/helpful").should == "/tmp/assets/helpers/helpful"
    end

    it "searches the core ASSETS_PATH if GITTY_ASSETS is not defined" do
      ENV.stub!(:[]).with("GITTY_ASSETS").and_return(nil)
      File.stub!(:exist?).with((ASSETS_PATH + "helpers/helpful").to_s).and_return(true)
      Gitty.find_asset("helpers/helpful").should == (ASSETS_PATH + "helpers/helpful").to_s
    end

    it "returns nil if none the file is not found" do
      Gitty.find_asset("willy/wonka").should be_nil
    end
  end

  describe ".extract_meta_data" do
    it "extracts meta data from a stream" do
      stream = <<-EOF
#!/usr/bash

# description: hi
# targets: ["post-merge", "post-checkout"]
#

here's my hook
EOF
      Gitty.extract_meta_data(stream).should == {
        "description" => "hi",
        "targets" => ["post-merge", "post-checkout"]
      }
    end
  end
end
