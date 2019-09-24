require "rails_helper"
require "gds_api/test_helpers/publishing_api"

describe "root resource" do
  describe "/" do
    it "should not error" do
      get "/"
      expect(response.status).to eql(200)
    end
  end

  describe "/documentation" do
    it "should not error" do
      get "/documentation"
      expect(response.status).to eql(200)
    end
  end

  describe "/readme" do
    it "should redirect" do
      get "/readme"
      expect(response.status).to eql(301)
      expect(response).to redirect_to("/documentation")
    end
  end
end
