def load_and_parse_schema(filename)
	 schema_filepath = File.join(Rails.root, "public", filename)
	JSON.parse(File.read(schema_filepath))
end

MANUAL_SCHEMA = load_and_parse_schema("manual-schema.json")
SECTION_SCHEMA = load_and_parse_schema("section-schema.json")
