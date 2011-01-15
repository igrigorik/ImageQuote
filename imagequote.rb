require 'rubygems'
require 'sinatra'
require 'helper'

def render_image(text, from)
  quote = Image.read("quote.png").first

  RVG::dpi = 72

  bg = RVG.new(800.px, 480.px) do |canvas|
    canvas.background_fill = 'black'
  end.draw

  text  = render_cropped_text(text, 620, 430) do |img|
    img.fill = "#ffffff" # font color
    img.background_color = "transparent"
    img.pointsize = 23
    img.antialias = true
  end

  src = render_cropped_text(from, 620, 40) do |img|
    img.fill = "#cccccc" # font color
    img.background_color = "transparent"
    img.pointsize = 18
    img.antialias = true
  end

  quote.page = Rectangle.new(quote.rows,quote.columns,15,30)
  text.page  = Rectangle.new(text.rows,text.columns,105,65)
  src.page   = Rectangle.new(src.rows,src.columns,105,430)

  r = ImageList.new
  r << bg << quote << text << src
end

get "/" do
  erb :index
end

get "/quote" do
  content_type 'image/png'

  r = render_image(params[:quote], params[:source])
  r.flatten_images.to_blob {|i| i.format = 'PNG'}
end

post "/quote" do
  content_type 'image/png'

  r = render_image(params[:quote], params[:source])
  r.flatten_images.to_blob {|i| i.format = 'PNG'}
end