schema_filename = File.join(Rails.root, "public", "manual-schema.json")
MANUAL_SCHEMA = JSON.parse(File.read(schema_filename))
