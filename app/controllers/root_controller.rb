class RootController < ActionController::API
  include ActionController::UrlFor
  include ActionView::Layouts

  layout "application"

  def index
    render :index
  end

  def readme
    file_contents = File.open(Rails.root + "README.md", 'r').read
    markdown = Kramdown::Document.new(file_contents).to_html
    render :readme, locals: { markdown: markdown }, layout: true
  end
end
