require "rails_helper"

describe ValidSlug::PATTERN do
  it "matches good slugs" do
    expect("a-to-z").to match(ValidSlug::PATTERN)
  end

  it "does not match slugs with uppercase characters" do
    expect("aTOz").to_not match(ValidSlug::PATTERN)
  end

  it "does not match slugs with leading dashes" do
    expect("-atoz").to_not match(ValidSlug::PATTERN)
  end

  it "does not match slugs with leading dashes" do
    expect("atoz-").to_not match(ValidSlug::PATTERN)
  end

  it "does not match slugs with underscores" do
    expect("a_toz").to_not match(ValidSlug::PATTERN)
  end

  it "does not match slugs with consecutive dashes" do
    expect("a--toz").to_not match(ValidSlug::PATTERN)
  end
end
