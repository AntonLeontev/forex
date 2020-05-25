require 'json'
require 'nokogiri'

rate = {}

dollar = 75.0
euro   = 82.0

1589749200.step(1589752200, 60) { |i|
  minute_history = []

  60.times do |x|
    dollar = (dollar + rand(-0.02..0.02)).round(4)
    euro   = (euro   + rand(-0.02..0.02)).round(4)

    minute_history << (euro / dollar).round(4)
  end

  rate[i] = {
    'start'  => minute_history[0],
    'finish' => minute_history[-1],
    'max'    => minute_history.max,
    'min'    => minute_history.min 
  }

}

xml = Nokogiri::XML::Builder.new { |xml|
  xml.default_settings do
    xml.canvas_settings do
      xml.image_height "600"
      xml.image_width "550"
      xml.vertical_padding "10"

      xml.grid_settings do
        xml.grid_main_color "white"
        xml.grid_line_color "grey95"
        xml.grid_step "10"
      end
    end

    xml.candles_settings do
      xml.density "10"
      xml.thickness "7"
      xml.candle_stroke "green"
      xml.candle_fill "green"
      xml.candle_stroke_width "1"
      xml.up_candle_opacity "1"
      xml.down_candle_opacity "0"
      xml.start_date "1589749200"
      xml.finish_date "1589752200"
    end

    xml.scale_settings do
      xml.scale_margin "10"
      xml.scale_stroke "black"
      xml.scale_stroke_opacity "0"
      xml.scale_mark_size "10"
    end

    xml.test_settings do
      xml.font_size "14"
      xml.text_left_padding "5"
      xml.text_vert_padding "5"
    end
  end
}.to_xml

current_path = File.dirname(__FILE__)

File.write(current_path + '/data/candles/minute_candles_db.json', rate.to_json)
File.write(current_path + '/default_settings.xml', xml)




