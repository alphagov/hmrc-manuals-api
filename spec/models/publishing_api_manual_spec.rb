require "rails_helper"

describe PublishingAPIManual do
  describe ".base_path" do
    it "returns the GOV.UK path for the manual" do
      base_path = PublishingAPIManual.base_path("some-manual")
      expect(base_path).to eql("/hmrc-internal-manuals/some-manual")
    end

    it "ensures that it is lowercase" do
      base_path = PublishingAPIManual.base_path("Some-Manual")
      expect(base_path).to eql("/hmrc-internal-manuals/some-manual")
    end
  end

  describe ".extract_slug_from_path" do
    it "finds the first path segment after the base path segment" do
      extracted_slug = described_class.extract_slug_from_path("/hmrc-internal-manuals/what-a-slug")
      expect(extracted_slug).to eq("what-a-slug")
    end

    it "ignores trailing slashes" do
      extracted_slug = described_class.extract_slug_from_path("/hmrc-internal-manuals/what-a-slug/")
      expect(extracted_slug).to eq("what-a-slug")
    end

    it "ignores path segments after the first one" do
      extracted_slug = described_class.extract_slug_from_path("/hmrc-internal-manuals/what-a-slug/section-slug")
      expect(extracted_slug).to eq("what-a-slug")
    end

    it "raises an InvalidPathErrorInvalidPathError exception if the path is blank" do
      expect {
        described_class.extract_slug_from_path("")
      }.to raise_error(InvalidPathError)
    end

    it "raises an InvalidPathError exception if the path does not start with the base path segment" do
      expect {
        described_class.extract_slug_from_path("/fco-travel-advice/dont-go-back-to-rockville")
      }.to raise_error(InvalidPathError)
    end

    it "raises an InvalidPathError exception if the path does start with the base path segment, but has no 2nd path segment" do
      expect {
        described_class.extract_slug_from_path("/hmrc-internal-manuals/")
      }.to raise_error(InvalidPathError)
    end
  end

  subject(:publishing_api_manual) { PublishingAPIManual.new(slug, attributes) }
  let(:slug) { "some-slug" }
  let(:attributes) { valid_manual }

  describe "#to_h" do
    subject { publishing_api_manual.to_h }

    context "valid_manual" do
      it { should be_valid_against_publisher_schema("hmrc_manual") }
    end

    context "maximal_manual" do
      let(:attributes) { maximal_manual }

      it { should be_valid_against_publisher_schema("hmrc_manual") }
    end
  end

  describe "content_id" do
    context "when content id is specified in the attributes" do
      let(:content_id) { SecureRandom.uuid }
      let(:attributes) { valid_manual.merge("content_id" => content_id) }

      it "returns the content_id" do
        expect(subject.content_id).to eq content_id
      end
    end

    context "when content id is absent from the attributes" do
      it "generates one from the base path" do
        expect(attributes["content_id"]).to be nil
        expect(subject.content_id).to eq UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, subject.base_path).to_s
      end
    end
  end

  describe "validations" do
    context "validating slug format" do
      it { should_not allow_value(nil, "1Som\nSłu9G!").for(:slug) }
    end

    context "with an empty payload" do
      let(:attributes) { {} }
      it { should_not be_valid }
    end

    context "with an invalid payload" do
      let(:attributes) { [] }
      it { should_not be_valid }
    end

    context "with an invalid title" do
      let(:attributes) { valid_manual(title: "title <script></script>") }

      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject).to have(1).error_on(:base)
        expect(subject.errors.full_messages[0]).to match(%r{'#/title' contains disallowed HTML})
      end
    end

    context "with invalid child section groups" do
      let(:child_section_group_with_dangerous_title) { { "title" => "title <script></script>", "child_sections" => [] } }
      let(:attributes) { valid_manual("details" => { "child_section_groups" => [child_section_group_with_dangerous_title] * 2 }) }

      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject).to have(2).errors_on(:base)
        expect(subject.errors.full_messages[0]).to match(
          %r{'#/details/child_section_groups\[0\]/title' contains disallowed HTML},
        )
        expect(subject.errors.full_messages[1]).to match(
          %r{'#/details/child_section_groups\[1\]/title' contains disallowed HTML},
        )
      end
    end

    context "when app is configured to only allow known slugs" do
      before do
        allow(HmrcManualsApi::Application.config).to receive(:allow_unknown_hmrc_manual_slugs).and_return(false)
      end

      context "with a manual slug name not in list of known slugs" do
        let(:slug) { "non-existent-slug" }
        it { should_not be_valid }
      end

      context "with a manual slug name in list of known slugs" do
        let(:slug) { KNOWN_MANUAL_SLUGS.first }
        it { should be_valid }
      end
    end

    context "when app is configured to allow unknown slugs" do
      before do
        allow(HmrcManualsApi::Application.config).to receive(:allow_unknown_hmrc_manual_slugs).and_return(true)
      end

      context "with a manual slug name not in list of known slugs" do
        let(:slug) { "non-existent-slug" }
        it { should be_valid }
      end

      context "with a manual slug name in list of known slugs" do
        let(:slug) { KNOWN_MANUAL_SLUGS.first }
        it { should be_valid }
      end
    end
  end
end
