require 'rails_helper'

describe NoHtmlInTextFieldsValidator do
  class SomeModel
    include ActiveModel::Validations

    attr_reader :data
    validates :data, no_html_in_text_fields: true

    def initialize(data)
      @data = data
    end
  end

  subject { SomeModel.new(title: "title <b>abc</b>") }

  it "marks text fields with HTML as invalid" do
    expect(subject).to_not be_valid
    expect(subject).to have(1).error_on(:base)
    expect(subject.errors[:base].first).to eq("'#/title' contains HTML, which isn't allowed.")
  end
end
