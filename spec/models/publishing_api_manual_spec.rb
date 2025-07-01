require "rails_helper"
require "gds_api/test_helpers/content_store"

describe PublishingAPIManual do
  include GdsApi::TestHelpers::ContentStore

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

    context "valid_manual_without_change_note_titles" do
      let(:attributes) { manual_without_change_note_titles }
      let(:path_1) { "/hmrc-internal-manuals/some-slug/abc567" }
      let(:path_2) { "/hmrc-internal-manuals/some-slug/abc555" }

      before do
        stub_content_store_has_item(path_1, content_item_for_base_path(path_1))
        stub_content_store_has_item(path_2, content_item_for_base_path(path_2))
      end

      it "adds the section title to the title field of the change note" do
        expect(subject.dig("details", "change_notes").first["title"]).to eq("Hmrc internal manuals some slug abc567")
        expect(subject.dig("details", "change_notes").second["title"]).to eq("Hmrc internal manuals some slug abc555")
      end
    end

    describe "section_id" do
      context "when a section_id is specified in a change note" do
        let(:attributes) { maximal_manual }

        it "adds the base_path of the sections" do
          expect(subject.dig("details", "change_notes", 0, "base_path")).to eq("/hmrc-internal-manuals/some-slug/abc567")
          expect(subject.dig("details", "change_notes", 1, "base_path")).to eq("/hmrc-internal-manuals/some-slug/abc555")
        end
      end

      context "when a section_id is not specified in a change note" do
        let(:attributes) { manual_with_top_level_change_note }

        it "adds the base_path of the manual to the change_note with the missing section_id" do
          expect(subject.dig("details", "change_notes", 0, "base_path")).to eq("/hmrc-internal-manuals/some-slug")
        end
      end
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
  end
end
