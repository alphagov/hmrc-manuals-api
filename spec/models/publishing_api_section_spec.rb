require "rails_helper"

describe PublishingAPISection do
  describe ".base_path" do
    it "returns the GOV.UK path for the section" do
      base_path = PublishingAPISection.base_path("some-manual", "some-section-id")
      expect(base_path).to eql("/hmrc-internal-manuals/some-manual/some-section-id")
    end

    it "ensures that it is lowercase" do
      base_path = PublishingAPISection.base_path("Some-Manual", "Some-Section-id")
      expect(base_path).to eql("/hmrc-internal-manuals/some-manual/some-section-id")
    end
  end

  describe ".extract_slugs_from_path" do
    it "finds the first path segment after the base path segment as the manual slug" do
      extracted_slugs = described_class.extract_slugs_from_path("/hmrc-internal-manuals/what-a-slug/for-a-section")
      expect(extracted_slugs[:manual]).to eq("what-a-slug")
    end

    it "finds the second path segment after the base path segment as the section slug" do
      extracted_slugs = described_class.extract_slugs_from_path("/hmrc-internal-manuals/what-a-slug/for-a-section")
      expect(extracted_slugs[:section]).to eq("for-a-section")
    end

    it "ignores trailing slashes" do
      extracted_slugs = described_class.extract_slugs_from_path("/hmrc-internal-manuals/what-a-slug/for-a-section/")
      expect(extracted_slugs[:section]).to eq("for-a-section")
    end

    it "ignores path segments after the second one" do
      extracted_slugs = described_class.extract_slugs_from_path("/hmrc-internal-manuals/what-a-slug/for-a-section/and-another/thing")
      expect(extracted_slugs[:section]).to eq("for-a-section")
    end

    it "raises an InvalidPathErrorInvalidPathError exception if the path is blank" do
      expect {
        described_class.extract_slugs_from_path("")
      }.to raise_error(InvalidPathError)
    end

    it "raises an InvalidPathError exception if the link does not start with the base path segment" do
      expect {
        described_class.extract_slugs_from_path("/fco-travel-advice/dont-go-back-to-rockville")
      }.to raise_error(InvalidPathError)
    end

    it "raises an InvalidPathError exception if the link does start with the base path segment, but has no 2nd path segment" do
      expect {
        described_class.extract_slugs_from_path("/hmrc-internal-manuals/")
      }.to raise_error(InvalidPathError)
    end

    it "raises an InvalidPathError exception if the path does start with the base path segment, but has no 3rd path segment" do
      expect {
        described_class.extract_slugs_from_path("/hmrc-internal-manuals/what-a-slug")
      }.to raise_error(InvalidPathError)
    end
  end

  subject(:publishing_api_section) do
    PublishingAPISection.new(manual_slug, section_slug, attributes)
  end
  let(:manual_slug) { "some-slug" }
  let(:section_slug) { "some_id" }

  describe "#to_h" do
    let(:subject) { publishing_api_section.to_h }

    context "valid_section" do
      let(:attributes) { valid_section }

      it { should be_valid_against_publisher_schema("hmrc_manual_section") }
    end

    context "maximal_section" do
      let(:attributes) { maximal_section }

      it { should be_valid_against_publisher_schema("hmrc_manual_section") }
    end
  end

  describe "content_id" do
    context "when content id is present" do
      let(:content_id) { SecureRandom.uuid }
      let(:attributes) { valid_section.merge("content_id" => content_id) }

      it "returns the context id" do
        expect(subject.content_id).to eq content_id
      end
    end

    context "when content id is absent" do
      let(:attributes)  { valid_section }
      it "generates one from the base path" do
        expect(attributes["content_id"]).to be nil
        expect(subject.content_id).to eq UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, subject.base_path).to_s
      end
    end
  end

  describe "validations" do
    context "validating slug format" do
      let(:attributes) { valid_section }

      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:manual_slug) }
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:section_slug) }
    end

    context "mismatched section ID and slug" do
      subject { PublishingAPISection.new("manual", "mismatch", valid_section) }

      it { should_not be_valid }

      it "rejects mismatches" do
        subject.valid? # trigger validations and populate errors
        expect(subject.errors[:base].first).to eql("Slug in URL and Section ID must match, ignoring case")
      end
    end

    context "with an empty payload" do
      let(:attributes) { {} }
      it { should_not be_valid }
    end

    context "with an invalid payload" do
      let(:attributes) { [] }
      it { should_not be_valid }
    end

    context "when app is configured to only allow known manual slugs" do
      let(:attributes) { valid_section }
      # section_slug and section_id have to match to pass `:section_slug_matches_section_id` validation
      let(:section_slug) { valid_section["details"]["section_id"] }

      before do
        allow(HmrcManualsApi::Application.config).to receive(:allow_unknown_hmrc_manual_slugs).and_return(false)
      end

      context "with a manual slug name not in list of known slugs" do
        let(:manual_slug) { "non-existent-slug" }
        it { should_not be_valid }
      end

      context "with a manual slug name in list of known slugs" do
        let(:manual_slug) { KNOWN_MANUAL_SLUGS.first }
        it { should be_valid }
      end
    end
  end
end
