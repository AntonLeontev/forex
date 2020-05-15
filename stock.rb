require 'rmagick'
require "json"
require_relative 'methods.rb'

# frozen_string_literal: true

rate = JSON.parse(File.read('candles_db.json'))


# View settings
density          = 10   # плотность отображения японских свеч
thickness        = 7    # толщина одной свечи
image_height     = 500  # высота создаваемого изображения в пкс
image_width      = 600  # ширина создаваемого изображения в пкс
vertical_padding = 10   # размер верхнего и нижнего поля изображения


top_extremum = to_points(rate.map { |x| x[1]['max']}.max)
low_extremum = to_points(rate.map { |x| x[1]['min']}.min)
scale_ratio = (image_height.to_f - vertical_padding * 2) /
  (top_extremum - low_extremum)


canvas = Magick::ImageList.new
canvas.new_image(
  image_width, image_height, Magick::HatchFill.new('white', 'gray93')
  )

candle = Magick::Draw.new
candle.stroke('green')
candle.fill('green')
candle.stroke_width(1)

60.times { |i|

  if rate[i.to_s]["start"] > rate[i.to_s]["finish"]
    candle.fill_opacity(0)
  else
    candle.fill_opacity(1)
  end

  candle.rectangle(
    i * density, 
    (top_extremum - to_points(rate[i.to_s]["start"])) * 
      scale_ratio + vertical_padding,
    i * density + thickness, 
    (top_extremum - to_points(rate[i.to_s]["finish"])) * 
      scale_ratio + vertical_padding + 1
  )

  high_end      = [rate[i.to_s]["start"], rate[i.to_s]["finish"]].max
  low_end       = [rate[i.to_s]["start"], rate[i.to_s]["finish"]].min
  candle_centre = i * density + thickness / 2

  if rate[i.to_s]["max"] != high_end
    candle.line(
      candle_centre, 
      (top_extremum - to_points(high_end)) * 
        scale_ratio + vertical_padding,
      candle_centre, 
      (top_extremum - to_points(rate[i.to_s]["max"])) * 
        scale_ratio + vertical_padding
    )
  end

  if rate[i.to_s]["min"] != low_end
    candle.line(
      candle_centre, 
      (top_extremum - to_points(low_end)) * 
        scale_ratio + vertical_padding + 1,
      candle_centre, 
      (top_extremum - to_points(rate[i.to_s]['min'])) * 
        scale_ratio + vertical_padding
    )
  end
}

candle.draw(canvas)
canvas.write('test.jpg')
