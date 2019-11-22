require "rails_helper"

describe SectionRetriever do
  describe "#sections_from_search_api" do
    subject(:section_retriever) { described_class.new("some-manual-slug") }

    it "asks Search API for all the hmrc manual sections under its slug" do
      search_api_query = stub_request(:get, %r{/search.json})
        .to_return(body: no_manual_sections_rummager_json_result)

      subject.sections_from_search_api.map { |json| PublishingAPIRemovedSection.from_search_api_result(json) }

      assert_requested search_api_query
    end

    it "exposes each result from Search API as the specified Section type" do
      stub_request(:get, %r{/search.json})
        .to_return(body: two_manual_sections_rummager_json_result("some-manual-slug"))

      sections = subject.sections_from_search_api.map { |json| PublishingAPIRemovedSection.from_search_api_result(json) }
      expect(sections.size).to eq(2)

      expect(sections.first).to be_a PublishingAPIRemovedSection
      expect(sections.first.manual_slug).to eq("some-manual-slug")
      expect(sections.first.section_slug).to eq("section-1")

      expect(sections.last).to be_a PublishingAPIRemovedSection
      expect(sections.last.manual_slug).to eq("some-manual-slug")
      expect(sections.last.section_slug).to eq("section-2")
    end

    it "exposes the error from Search API if the Search API call fails" do
      stub_request(:get, %r{/search.json})
        .to_return(status: 503, body: '{"error":"arg!"}')

      expect {
        subject.sections_from_search_api.map { |json| PublishingAPIRemovedSection.from_search_api_result(json) }
      }.to raise_error(GdsApi::BaseError)
    end

    describe "paging through sections" do
      subject(:section_retriever) { described_class.new("some-manual-slug") }

      it "gets all sections when there is more than one page of results" do
        stub_request(:get, %r{/search.json?.+start=0})
          .to_return(body: one_of_two_manual_sections_rummager_json_result("some-manual-slug"))

        stub_request(:get, %r{/search.json?.+start=1})
          .to_return(body: two_of_two_manual_sections_rummager_json_result("some-manual-slug"))

        sections = subject.sections_from_search_api.map { |json| PublishingAPIRedirectedSectionToParentManual.from_search_api_result(json) }
        expect(sections.size).to eq(2)

        expect(sections.first).to be_a PublishingAPIRedirectedSectionToParentManual
        expect(sections.first.manual_slug).to eq("some-manual-slug")
        expect(sections.first.section_slug).to eq("section-1")

        expect(sections.last).to be_a PublishingAPIRedirectedSectionToParentManual
        expect(sections.last.manual_slug).to eq("some-manual-slug")
        expect(sections.last.section_slug).to eq("section-2")
      end
    end
  end
end
