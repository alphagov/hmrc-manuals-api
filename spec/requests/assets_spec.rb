require "rails_helper"

describe "assets resource" do
  describe "POST /assets" do
    subject do
      post_multipart "/assets", {}
    end

    it "responds with ok" do
      subject

      expect(response.status).to eq(200)
    end
  end
end
