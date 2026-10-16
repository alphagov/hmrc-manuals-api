require "rails_helper"

describe ApiPaths do
  describe ".include?" do
    it "matches exact API paths" do
      expect(described_class.include?("/assets")).to be(true)
      expect(described_class.include?("/hmrc-manuals")).to be(true)
    end

    it "matches paths under an API prefix" do
      expect(described_class.include?("/assets/")).to be(true)
      expect(described_class.include?("/assets/0ebc9800-94c4-013f-fb0a")).to be(true)
      expect(described_class.include?("/hmrc-manuals/slug/sections/another-slug")).to be(true)
    end

    it "matches attempted paths including a query string" do
      expect(described_class.include?("/assets/0ebc9800-94c4-013f-fb0a?dry_run=true")).to be(true)
    end

    it "rejects paths that merely look like an API prefix" do
      expect(described_class.include?("/assets-admin")).to be(false)
      expect(described_class.include?("/assets.json")).to be(false)
      expect(described_class.include?("/hmrc-manuals-api")).to be(false)
    end

    it "rejects non-API paths" do
      expect(described_class.include?("/")).to be(false)
      expect(described_class.include?("/healthcheck/live")).to be(false)
      expect(described_class.include?("/definitely-non-existent")).to be(false)
    end
  end
end
