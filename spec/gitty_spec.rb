require 'spec_helper'

describe Gitty do
  describe ".asset_file" do
    it "searches first in the specified $GITTY_ASSETS environment variable" do
      # this is bad form, but I can't think of a better way to test this. Likely a symptom of bad design.
      Gitty.stub!(:asset_paths).and_return ["/tmp/assets", ASSETS_PATH]
      File.stub!(:exist?).with("/tmp/assets/helpers/helpful").and_return(true)
      File.stub!(:exist?).with(ASSETS_PATH + "helpers/helpful").and_return(true)

      Gitty.find_asset("helpers/helpful").should == "/tmp/assets/helpers/helpful"
    end

    it "returns nil if none the file is not found" do
      Gitty.find_asset("willy/wonka").should be_nil
    end
  end
end
