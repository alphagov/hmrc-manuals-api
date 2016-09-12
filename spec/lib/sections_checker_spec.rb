require 'rails_helper'
require 'gds_api/test_helpers/content_store'

RSpec.describe SectionsChecker do
  include GdsApi::TestHelpers::ContentStore

  context 'when given a manual slug' do
    let(:manual_slug) { 'a-manual-slug' }
    let(:manual_path) { PublishingAPIManual.base_path(manual_slug) }
    let(:content_item) { hmrc_manual_content_item_for_base_path(manual_path, child_section_groups: child_section_groups) }
    before do
      content_store_has_item(manual_path, content_item)
    end

    context 'and the manual has no child sections' do
      let(:child_section_groups) { [] }
      it 'returns the empty array' do
        expect(described_class.new(manual_slug).check).to be_empty
      end
    end

    context 'and the manual has some child sections' do
      let(:child_section_groups) do
        [
          {
            "child_sections" => [
              {
                "section_id" => "DT1690PP",
                "title" => "Income arising in the United Kingdom to non-residents: contents",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-1"
              },
              {
                "section_id" => "DT2100",
                "title" => "Scope of this guidance",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-2"
              }
            ]
          },
          {
            "child_sections" => [
              {
                "section_id" => "DT2140PP",
                "title" => "Guidance by country: contents",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-3"
              }
            ]
          }
        ]
      end
      let(:child_1_base_path) { PublishingAPISection.base_path(manual_slug, 'child-1') }
      let(:child_2_base_path) { PublishingAPISection.base_path(manual_slug, 'child-2') }
      let(:child_3_base_path) { PublishingAPISection.base_path(manual_slug, 'child-3') }
      let(:new_manual_slug) { 'a-new-manual-slug' }
      let(:new_manual_path) { PublishingAPIManual.base_path(new_manual_slug) }
      let(:new_manual_content_item) do
        hmrc_manual_content_item_for_base_path(
          new_manual_path,
          child_section_groups: new_manual_child_section_groups
        )
      end
      let(:new_manual_child_section_groups) { [] }

      before do
        child_1_content_item = hmrc_manual_section_content_item_for_base_path(
          child_1_base_path,
          manual_base_path: manual_path
        )

        child_2_content_item = hmrc_manual_section_content_item_for_base_path(
          child_2_base_path,
          manual_base_path: new_manual_path
        )

        child_3_content_item = hmrc_manual_section_content_item_for_base_path(
          child_3_base_path,
          manual_base_path: manual_path
        )

        content_store_has_item(child_1_base_path, child_1_content_item)
        content_store_has_item(child_2_base_path, child_2_content_item)
        content_store_has_item(child_3_base_path, child_3_content_item)
        content_store_has_item(new_manual_path, new_manual_content_item)
      end

      subject { described_class.new(manual_slug).check }

      it 'returns the children that still belong to this manual' do
        expect(subject).to include(child_1_base_path)
        expect(subject).to include(child_3_base_path)
      end

      context 'and there is a child that has been reparented' do
        let(:child_5_base_path) { PublishingAPISection.base_path(new_manual_slug, 'child-5') }
        let(:child_6_base_path) { PublishingAPISection.base_path(new_manual_slug, 'child-6') }
        let(:new_manual_child_section_groups) do
          [
            {
              "child_sections" => [
                {
                  "section_id" => "DT1690PP",
                  "title" => "Income arising in the United Kingdom to non-residents: contents",
                  "description" => "",
                  "base_path" => "/hmrc-internal-manuals/#{new_manual_slug}/child-5"
                },
                {
                  "section_id" => "DT2100",
                  "title" => "Scope of this guidance",
                  "description" => "",
                  "base_path" => "/hmrc-internal-manuals/#{new_manual_slug}/child-6"
                }
              ]
            }
          ]
        end

        before do
          child_5_content_item = hmrc_manual_section_content_item_for_base_path(
            child_5_base_path,
            manual_base_path: new_manual_path
          )

          child_6_content_item = hmrc_manual_section_content_item_for_base_path(
            child_6_base_path,
            manual_base_path: new_manual_path,
            child_section_groups: new_section_child_section_group
          )

          content_store_has_item(child_5_base_path, child_5_content_item)
          content_store_has_item(child_6_base_path, child_6_content_item)
        end

        context 'when the new manual parent does contain the section' do
          let(:new_section_child_section_group) do
            [
              {
                "child_sections" => [
                  {
                    "section_id" => "DT1690PP",
                    "title" => "Income arising in the United Kingdom to non-residents: contents",
                    "description" => "",
                    "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-2"
                  }
                ]
              }
            ]
          end

          it 'does not return the reparented section' do
            expect(subject).not_to include(child_2_base_path)
          end
        end

        context 'when the new manual parent does not contain the section' do
          let(:new_section_child_section_group) { [] }

          it 'returns the incorrectly reparented child' do
            expect(subject).to include(child_2_base_path)
          end
        end
      end
    end
  end

  context 'when given a section slug' do
    let(:manual_slug) { 'a-manual-slug' }
    let(:section_slug) { 'a-section-slug' }
    let(:full_section_slug) { "#{manual_slug}/#{section_slug}" }
    let(:manual_path) { PublishingAPIManual.base_path(manual_slug) }
    let(:section_path) { PublishingAPISection.base_path(manual_slug, section_slug) }
    let(:content_item) do
      hmrc_manual_section_content_item_for_base_path(
        section_path,
        child_section_groups: child_section_groups,
        manual_base_path: manual_path
      )
    end

    before do
      content_store_has_item(section_path, content_item)
    end

    context 'and the section has no child sections' do
      let(:child_section_groups) { [] }
      it 'returns the empty array' do
        expect(described_class.new(full_section_slug).check).to be_empty
      end
    end

    context 'and the section has some child sections' do
      let(:child_section_groups) do
        [
          {
            "child_sections" => [
              {
                "section_id" => "DT1690PP",
                "title" => "Income arising in the United Kingdom to non-residents: contents",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-1"
              },
              {
                "section_id" => "DT2100",
                "title" => "Scope of this guidance",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-2"
              }
            ]
          },
          {
            "child_sections" => [
              {
                "section_id" => "DT2140PP",
                "title" => "Guidance by country: contents",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-3"
              }
            ]
          }
        ]
      end
      let(:child_1_base_path) { PublishingAPISection.base_path(manual_slug, 'child-1') }
      let(:child_2_base_path) { PublishingAPISection.base_path(manual_slug, 'child-2') }
      let(:child_3_base_path) { PublishingAPISection.base_path(manual_slug, 'child-3') }
      let(:new_section_path) { PublishingAPISection.base_path(manual_slug, 'a-new-section-slug') }

      before do
        child_1_content_item = hmrc_manual_section_content_item_for_base_path(
          child_1_base_path,
          manual_base_path: manual_path,
          breadcrumbs: [
            {
              "section_id" => "SECTION ID ONE",
              "base_path" => section_path
            }
          ]
        )

        child_2_content_item = hmrc_manual_section_content_item_for_base_path(
          child_2_base_path,
          manual_base_path: manual_path,
          breadcrumbs: [
            {
              "section_id" => "SECTION ID TWO",
              "base_path" => new_section_path
            }
          ]
        )

        child_3_content_item = hmrc_manual_section_content_item_for_base_path(
          child_3_base_path,
          manual_base_path: manual_path,
          breadcrumbs: [
            {
              "section_id" => "SECTION ID ONE",
              "base_path" => section_path
            }
          ]
        )

        content_store_has_item(child_1_base_path, child_1_content_item)
        content_store_has_item(child_2_base_path, child_2_content_item)
        content_store_has_item(child_3_base_path, child_3_content_item)

        new_section_content_item = hmrc_manual_section_content_item_for_base_path(
          new_section_path,
          manual_base_path: manual_path,
          child_section_groups: [
            {
              "child_sections" => [
                {
                  "section_id" => "DT1690PP",
                  "title" => "Income arising in the United Kingdom to non-residents: contents",
                  "description" => "",
                  "base_path" => child_2_base_path
                }
              ]
            }
          ]
        )
        content_store_has_item(new_section_path, new_section_content_item)
      end

      subject { described_class.new(full_section_slug).check }

      it 'returns the children that still belong to this manual' do
        expect(subject).to include(child_1_base_path)
        expect(subject).to include(child_3_base_path)
      end

      it 'does not return a child if it has been reparented' do
        expect(subject).not_to include(child_2_base_path)
      end
    end

    context 'section does not have the correct new parent' do
      let(:child_section_groups) do
        [
          {
            "child_sections" => [
              {
                "section_id" => "DT2100",
                "title" => "Scope of this guidance",
                "description" => "",
                "base_path" => "/hmrc-internal-manuals/#{manual_slug}/child-2"
              }
            ]
          }
        ]
      end
      let(:child_2_base_path) { PublishingAPISection.base_path(manual_slug, 'child-2') }
      let(:new_section_path) { PublishingAPISection.base_path(manual_slug, 'a-new-section-slug') }

      before do
        child_2_content_item = hmrc_manual_section_content_item_for_base_path(
          child_2_base_path,
          manual_base_path: manual_path,
          breadcrumbs: [
            {
              "section_id" => "SECTION ID TWO",
              "base_path" => new_section_path
            }
          ]
        )

        content_store_has_item(child_2_base_path, child_2_content_item)

        new_section_content_item = hmrc_manual_section_content_item_for_base_path(
          new_section_path,
          manual_base_path: manual_path,
          child_section_groups: []
        )
        content_store_has_item(new_section_path, new_section_content_item)
      end

      subject { described_class.new(full_section_slug).check }

      it 'returns the base path of the offending section' do
        expect(subject).to include(child_2_base_path)
      end
    end
  end

  def hmrc_manual_content_item_for_base_path(base_path, child_section_groups:[])
    item = content_item_for_base_path(base_path)
    item.merge(
      "format" => MANUAL_FORMAT,
      "details" => item["details"].merge(
        "child_section_groups" => child_section_groups
      )
    )
  end

  def hmrc_manual_section_content_item_for_base_path(base_path, child_section_groups:[], breadcrumbs:[], manual_base_path: "")
    item = content_item_for_base_path(base_path)
    item.merge(
      "format" => SECTION_FORMAT,
      "details" => item["details"].merge(
        "child_section_groups" => child_section_groups,
        "breadcrumbs" => breadcrumbs,
        "manual" => { "base_path" => manual_base_path }
      )
    )
  end
end
