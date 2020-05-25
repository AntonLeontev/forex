class GraphWindow < Magick::ImageList

  def initialize(settings)
    super()

    self.new_image(settings["image_width"], 
                   settings["image_height"], 
                   Magick::HatchFill.new(settings["grid_main_color"],
                                         settings["grid_line_color"],
                                         settings["grid_step"]))

    GraphImage.take_and_process(settings)
    Candles.new.draw(self)
    LeftScale.new.draw(self)
    # RightScale.new.(settings) .right_scale.draw(self)
    # BottomScale.new.(settings).bottom_scale.draw(self)
  end
end

class GraphImage < Magick::Draw

  class << self
    attr_reader :settings

    def take_and_process(settings)
      @settings = add_params(settings)
    end

    private

    def add_params(hash)
      hash["history"]          = to_points(rate_history)
      hash["top_extremum"]     = top_extremum(hash["history"])
      hash["low_extremum"]     = low_extremum(hash["history"])
      hash["amplitude"]        = amplitude(hash)
      hash["scale_ratio"]      = scale_ratio(hash)
      hash["page_bottom"]      = page_bottom(hash)
      hash["page_top"]         = page_top(hash)
      hash["scale_main_step"]  = scale_step(hash["amplitude"])
      # hash["scale_small_step"] = scale_small_step
      hash
    end

    def rate_history
      JSON.parse(File.read('data/candles/' + 
        'minute_candles_db.json')).transform_keys { |k| k.to_i}
    end

    def top_extremum(history)
      history.map { |x| x[1]['max'] }.max
    end

    def low_extremum(history)
      history.map { |x| x[1]['min'] }.min
    end

    def amplitude(hash)
      hash["top_extremum"] - hash["low_extremum"]
    end

    def scale_ratio(hash)
      (hash["image_height"].to_f -
        hash["vertical_padding"] * 2) / hash["amplitude"]
    end

    def page_bottom(hash)
      (hash["low_extremum"] - hash["vertical_padding"] / 
        hash["scale_ratio"]).ceil
    end

    def page_top(hash)
      (hash["top_extremum"] + hash["vertical_padding"] / 
        hash["scale_ratio"]).floor
    end


  def scale_step(amplitude) 
    case amplitude
    when 0..5
      1
    when 6..12
      2
    when 13..22
      5
    when 23..45
      10
    when 46..90
      20
    when 90..110
      25
    when 111..180
      40
    when 181..270
      50
    when 271..320
      75
    when 321...650
      100
    else
      handsome_round(amplitude)
    end
  end

  def handsome_round(amplitude) 
    number = amplitude / 5
    arr    = number.digits.reverse

    if (3..7).any?(arr[1]) 
      arr[1] = 5
    elsif (0..2).any?(arr[1])
      arr[1] = 0
    else
      arr[0] += 1
      arr[1] = 0
    end

    (2...arr.size).each { |i| arr[i] = 0 }
    arr.join.to_i
  end

    def to_points(rate_history) 
      rate_history.each_key do |key|
        rate_history[key].each_pair do |k, v| 
          rate_history[key][k] = (v * 10_000).round 
        end
      end
    end
  end

  def initialize
    super
  end


  private
  
  def to_graph(value, settings)
    (settings["top_extremum"] - value) * 
      settings["scale_ratio"] + settings["vertical_padding"]
  end
end

class Candles < GraphImage

  def initialize
    super
    settings = GraphImage.settings

    self.stroke(settings["candle_stroke"])
    self.fill(settings["candle_fill"])
    self.stroke_width(settings["candle_stroke_width"])

    settings["start_date"].step(settings["finish_date"], 60).with_index do 
      |i, nth_candle|
      
      paint_candle(i, settings)
      draw_candle_body(i, nth_candle, settings)
      draw_candle_shadows(i, nth_candle, settings)
    end
  end


  private

  def paint_candle(i, settings)
    if settings["history"][i]['start'] < settings["history"][i]['finish']
      self.fill_opacity(settings["up_candle_opacity"])
    else
      self.fill_opacity(settings["down_candle_opacity"])
    end
  end


  def draw_candle_body(i, nth_candle, settings)
    start  = settings["history"][i]["start"]
    finish = settings["history"][i]["finish"]

    self.rectangle(
          nth_candle * settings["density"],
          to_graph(start, settings),

          nth_candle * settings["density"] + settings["thickness"],
          to_graph(finish, settings) + 1,
        )
  end


  def draw_candle_shadows(i, nth_candle, settings)
    start  = settings["history"][i]["start"]
    finish = settings["history"][i]["finish"]
    min    = settings["history"][i]["min"]
    max    = settings["history"][i]["max"]

    high_end = [start, finish].max
    low_end  = [start, finish].min
    middle   = nth_candle * settings["density"] + settings["thickness"] / 2

    if max != high_end
      self.line(
        middle,
        to_graph(high_end, settings),

        middle,
        to_graph(max, settings)
      )
    end

    if min != low_end

      self.line(
        middle,
        to_graph(low_end, settings) + 1,

        middle,
        to_graph(min, settings)
        )
    end
  end
end

class LeftScale < GraphImage
  def initialize
    super
    settings = GraphImage.settings

    self.stroke('black')
    self.stroke_opacity(settings["scale_stroke_opacity"])
    self.pointsize(settings["font_size"])
    self.line(settings["left_padding"],
              0,
              settings["left_padding"],
              settings["image_height"])

    first_mark = find_first_mark(settings)

    draw_main_marks(settings, first_mark)
    draw_small_marks

  end


  private

  def find_first_mark(settings)
    (settings["page_bottom"]..).find { |x| x % settings["scale_main_step"] == 0}
  end

  def draw_main_marks(settings, first_mark)
    first_mark.step(settings["page_top"], settings["scale_main_step"]) do
      |mark|

      position = to_graph(mark, settings)

      self.line(settings["left_padding"],
                position,
                settings["left_padding"] + 10,
                position)

      self.text(settings["left_padding"] + 5,
                position - 5,
                mark.to_s.insert(1, '.'))
    end
  end

  def draw_small_marks
    
  end

end

class RightScale < GraphImage

end

class BottomScale < GraphImage
end
