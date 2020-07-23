Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "publishing_api_notifier" => "PublishingAPINotifier",
    "publishing_api_section" => "PublishingAPISection",
    "publishing_api_removed_section" => "PublishingAPIRemovedSection",
    "publishing_api_manual" => "PublishingAPIManual",
    "publishing_api_removed_manual" => "PublishingAPIRemovedManual",
    "publishing_api_redirected_section_to_parent_manual" => "PublishingAPIRedirectedSectionToParentManual",
    "publishing_api_redirected_section" => "PublishingAPIRedirectedSection",
    "publishing_api_redirected_manual" => "PublishingAPIRedirectedManual",
    "publishing_api_helpers" => "PublishingAPIHelpers",
    "pattern" => "PATTERN",
    "invalid_json_error" => "InvalidJSONError",
  )
end
