require "spec_helper"
require "struct_with_rendered_markdown"

describe StructWithRenderedMarkdown do
  def conversion_of(struct)
    StructWithRenderedMarkdown.new(struct).to_h
  end

  it "renders markdown in 'body' fields to HTML" do
    expect(conversion_of("body" => "# Hello world", "a" => "b")).to eq(
      "body" => '<h1 id="hello-world">Hello world</h1>' + "\n", "a" => "b",
    )
  end

  it "recurses through arrays and hashes" do
    recursive_struct = {
      "a" => [
        "b" => {
          "body" => "**b**",
        },
        "c" => {
          "body" => "**c**",
        },
      ],
    }
    expect(conversion_of(recursive_struct)).to eq(
      "a" => [
        "b" => {
          "body" => "<p><strong>b</strong></p>\n",
        },
        "c" => {
          "body" => "<p><strong>c</strong></p>\n",
        },
      ],
    )
  end
end
