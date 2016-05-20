require 'spec_helper'
require 'structured_data'

describe StructuredData do
  def data(opts)
    StructuredData.new(opts)
  end

  it "finds string fields on the root" do
    expect(data(a: 1, b: "abc").string_fields).to eq([path: "#/b", value: "abc"])
  end

  it "finds nested string fields" do
    expect(data(a: 1, b: { c: "abc"}).string_fields).to eq([path: "#/b/c", value: "abc"])
  end

  it "finds string fields in arrays" do
    expect(data(a: 1, b: [{ c: "abc" }, { d: "xyz" }]).string_fields).to eq(
      [{ path: "#/b[0]/c", value: "abc" }, { path: "#/b[1]/d", value: "xyz" }]
    )
  end
end
