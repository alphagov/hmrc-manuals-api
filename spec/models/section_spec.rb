require 'rails_helper'

describe Section do
  context "with an empty payload" do
    subject { Section.new("some-slug", "some-section-id", {}) }

    it "is invalid" do
      expect(subject).to_not be_valid
    end
  end
end
