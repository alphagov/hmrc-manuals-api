require "rails_helper"

RSpec.configure do |c|
  c.include Helpers::PublishingAPIHelpers
end

RSpec.describe "Helpers::PublishingAPIHelpers" do
  describe "base_path_uuid" do
    before do
      allow_any_instance_of(Helpers::PublishingAPIHelpers)
        .to receive(:base_path)
        .and_return("/hmrc-internal-manuals/business-income-manual")
    end

    it "generates a consistent uuid from base_path" do
      expect(base_path_uuid).to eq("6c88e946-c722-5e73-9d6a-71da770d27a9")
    end
  end
end
