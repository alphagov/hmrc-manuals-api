class RootController < ActionController::Base
  include ActionController::UrlFor
  include ActionView::Layouts

  layout "application"

  def index
    render :index
  end

  def documentation
    content = load_documentation
    content = rewrite_public_links(content)
    render :documentation, locals: { content: content }, layout: true
  end

private

  def load_documentation
    file_contents = File.open(Rails.root + "docs/extended_documentation.md", 'r').read
    Kramdown::Document.new(file_contents).to_html
  end

  def rewrite_public_links(content)
    doc = Nokogiri::HTML.parse(content)
    doc.css("a[href^='/public/']", "a[href^='public/']").each do |anchor|
      # find all links with a path which starts "public" or "/public"
      new_path = anchor.attributes['href'].value.gsub(%r{^/?public}, '')
      anchor.attributes['href'].value = new_path
    end
    doc.to_html
  end
end
