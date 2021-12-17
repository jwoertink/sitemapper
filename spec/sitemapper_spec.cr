require "./spec_helper"

describe Sitemapper do
  describe "#build" do
    it "builds with config settings" do
      sitemaps = Sitemapper.build(&.add("/"))
      sitemaps.size.should eq 1
    end

    it "builds with explicit settings" do
      sitemaps = Sitemapper.build("host", 1, true, &.add("/"))
      sitemaps.size.should eq 2
    end
  end
end
