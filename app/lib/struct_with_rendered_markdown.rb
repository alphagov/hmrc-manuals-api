require "kramdown"

class StructWithRenderedMarkdown
  ATTRIBUTES_THAT_CAN_CONTAIN_MARKDOWN = %w[body].freeze

  def initialize(struct)
    @struct = struct.dup
  end

  def to_h
    render_markdown_in(@struct)
  end

private

  def render_markdown_in(struct)
    case struct
    when Array
      struct.each { |item| render_markdown_in(item) }
    when Hash
      struct.each do |key, value|
        if ATTRIBUTES_THAT_CAN_CONTAIN_MARKDOWN.include?(key)
          struct[key] = markdown_to_html(value)
        elsif value.is_a?(Hash) || value.is_a?(Array)
          render_markdown_in(value)
        end
      end
    end
    struct
  end

  def markdown_to_html(string)
    Kramdown::Document.new(string).to_html
  end
end
