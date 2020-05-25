class GraphWindow
  attr_reader :canvas

  def initialize(settings)

    @canvas = Magick::ImageList.new

    @canvas.new_image(settings["image_width"], 
                      settings["image_height"], 
                      Magick::HatchFill.new(settings["grid_main_color"],
                                            settings["grid_line_color"],
                                            settings["grid_step"]))

    Candles.new(settings)     .candles.draw(@canvas)
    # LeftScale.new.(settings)  .left_scale.draw(@canvas)
    # RightScale.new.(settings) .right_scale.draw(@canvas)
    # BottomScale.new.(settings).bottom_scale.draw(@canvas)
  end
end

class Candles
  attr_reader :candles

  def initialize(settings)
    @candles = Magick::Draw.new

    @candles.stroke('green')
    @candles.fill('green')
    @candles.stroke_width(1)

    settings["start_date"].step(settings["finish_date"], 60).with_index do 
      |i, nth_candle|
      
      paint_candle(i, settings)
      draw_candle_body(i, nth_candle, settings)
      draw_body_shadows(i, nth_candle, settings)
    end
  end
end

class LeftScale
  
end

class RightScale

end

class BottomScale
end
