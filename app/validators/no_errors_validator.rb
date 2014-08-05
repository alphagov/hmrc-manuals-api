class NoErrorsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    items = record.send(attribute)
    items.each {|e| record.errors[:base] << e }
  end
end
