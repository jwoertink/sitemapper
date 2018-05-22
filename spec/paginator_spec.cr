require "./spec_helper"

describe Sitemapper::Paginator do
  
  describe "#add" do
    it "stores a path and some builder options" do
      paginator = Sitemapper::Paginator.new
      paginator.add("/tacos", Sitemapper::Builder::DEFAULT_OPTIONS)
      paginator.paths.map(&.[0]).should contain "/tacos"
    end
  end

  describe "#items" do
    paginator = Sitemapper::Paginator.new(limit: 4)
    20.times { |i| paginator.add("/#{i}", Sitemapper::Builder::DEFAULT_OPTIONS) }

    it "returns the first 4 items" do
      items = paginator.items(1).map(&.[0])
      items.should contain "/0"
      items.should contain "/3"
      items.should_not contain "/4"
      items.size.should eq 4
    end

    it "returns the second set of 4" do
      items = paginator.items(2).map(&.[0])
      items.should contain "/4"
      items.should contain "/7"
      items.should_not contain "/3"
      items.size.should eq 4
    end
  end

  describe "#total_pages" do
    it "returns 1 page using a default limit of 500 with 20 items" do
      paginator = Sitemapper::Paginator.new
      20.times { |i| paginator.add("/#{i}", Sitemapper::Builder::DEFAULT_OPTIONS) }
      paginator.total_pages.should eq 1
    end

    it "returns 4 using a limit of 6 with 20 items" do
      paginator = Sitemapper::Paginator.new(limit: 6)
      20.times { |i| paginator.add("/#{i}", Sitemapper::Builder::DEFAULT_OPTIONS) }
      paginator.total_pages.should eq 4
    end
  end
end
