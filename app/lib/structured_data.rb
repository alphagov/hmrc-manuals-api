class StructuredData
  def initialize(struct)
    @struct = struct
  end

  def string_fields
    find_string_fields_in(@struct, "#")
  end

private

  def find_string_fields_in(struct, path)
    case struct
    when Hash
      struct.flat_map do |key, value|
        find_string_fields_in(value, "#{path}/#{key}")
      end
    when Array
      struct.flat_map.with_index do |value, index|
        find_string_fields_in(value, "#{path}[#{index}]")
      end
    when String
      [path: path, value: struct]
    else
      []
    end
  end
end
