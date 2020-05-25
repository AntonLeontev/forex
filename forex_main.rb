# frozen_string_literal: true

require 'rmagick'
require 'json'
require_relative 'classes.rb'
require_relative 'methods.rb'

settings = {
  "image_width"      => 1280, 
  "image_height"     => 720,
  "vertical_padding" => 10,
  "density"          => 14,
  "thickness"        => 10,
  "start_date"       => 1589749200,
  "finish_date"      => 1589752200,
  "grid_main_color"  => 'white',
  "grid_line_color"  => 'grey95',
  "grid_step"        => 10
}
graph_window = GraphWindow.new(settings)

# left_scale = Magick::Draw.new
# left_scale.stroke('black')
# left_scale.stroke_opacity(0)
# left_scale.pointsize(14)
# left_scale.line(10, 0, 10, 720)

# page_bottom = (low_extremum - 10 / scale_ratio).ceil
# page_top    = (top_extremum + 10 / scale_ratio).floor
# step        = scale_step(amplitude)

# first_mark = (page_bottom..).find { |x| x % step == 0 }

# first_mark.step(page_top, step) do |mark|
  

#   left_scale.line(
#     10,
#     (top_extremum - mark) * scale_ratio + 10,
#     20,
#     (top_extremum - mark) * scale_ratio + 10
#   )

#   left_scale.text(
#     15,
#     (top_extremum - mark) * scale_ratio + 5,
#    mark.to_s.insert(1, '.')
#   )
# end

graph_window.write('test.jpg')