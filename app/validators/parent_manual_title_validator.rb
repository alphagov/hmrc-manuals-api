class ParentManualTitleValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add :manual_title, "Unable to find parent manual's title as manual doesn't exist in Publishing API for base_path: #{record.to_h.dig('details', 'manual', 'base_path')}" unless record.to_h.dig("details", "manual", "title")
  end
end
