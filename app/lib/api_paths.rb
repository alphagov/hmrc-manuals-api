module ApiPaths
  PREFIXES = %w[/assets /hmrc-manuals].freeze

  def self.include?(path)
    PREFIXES.any? { |p| p == path || path.start_with?("#{p}/") }
  end
end
