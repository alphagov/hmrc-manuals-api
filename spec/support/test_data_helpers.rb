module TestDataHelpers
  def valid_manual(options = {})
    { title: 'Employment Income Manual' }.merge(options)
  end
end

RSpec.configuration.include TestDataHelpers
