require "./spec_helper"

describe Sitemapper::Config do
  describe "reset!" do
    it "resets all properties to their default state" do
      c = Sitemapper::Config.new
      c.use_index = true
      c.use_index.should eq true
      c.reset!
      c.use_index.should eq false
    end
  end
end
