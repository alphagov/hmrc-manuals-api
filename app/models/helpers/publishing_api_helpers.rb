module Helpers
  module PublishingAPIHelpers
    def add_absent_content_id(attributes)
      attributes["content_id"] = base_path_uuid unless attributes["content_id"]
      attributes
    end

    def base_path_uuid
      UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, base_path).to_s
    end
  end
end
