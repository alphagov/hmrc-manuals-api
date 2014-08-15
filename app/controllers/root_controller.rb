class RootController < ActionController::API
  include ActionController::UrlFor
  include ActionView::Layouts

  layout "application"

  def index
    render :index
  end

  def readme
    content = load_readme
    content = rewrite_public_links(content)
    render :readme, locals: { content: content }, layout: true
  end

private

  def load_readme
    file_contents = File.open(Rails.root + "README.md", 'r').read
    content = Kramdown::Document.new(file_contents).to_html
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
