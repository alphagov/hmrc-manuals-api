RSpec.shared_examples "it rejects the value as not matching" do
  it 'rejects them' do
    expect(errors).to_not be_empty
    expect(errors.first).to include("The property '#{json_path}' value #{value.to_json} did not match the regex")
  end
end

RSpec.shared_examples "it validates as a section ID" do
  context 'slashes' do
    let(:value) { "No/Slashes\\Allowed"}

    it_behaves_like "it rejects the value as not matching"
  end

  context 'spaces' do
    let(:value) { "No Spaces" }

    it_behaves_like "it rejects the value as not matching"
  end

  context 'underscores' do
    let(:value) { "No_Underscores" }

    it_behaves_like "it rejects the value as not matching"
  end
end
