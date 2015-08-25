require 'csv'

class ManualsToTopicsLoader
  def initialize(csv_data)
    @csv_data = csv_data
  end

  def load
    Hash[
      csv.map { |row|
        [
          manual_slug(row),
          content_ids(row),
        ]
      }
    ]
  end

private
  attr_reader :csv_data

  def csv
    CSV.parse(csv_data, headers: true)
  end

  def manual_slug(csv_row)
    csv_row[0]
  end

  def content_ids(csv_row)
    csv_row[2].split(",")
  end
end
