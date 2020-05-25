def add_params(hash)
  hash["history"]      = rate
  hash["top_extremum"] = top_extremum(hash["history"])
  hash["low_extremum"] = low_extremum(hash["history"])
  hash["amplitude"]    = amplitude(hash)
  hash["scale_ratio"]  = scale_ratio(hash)
  hash
end

def rate 
  rate = JSON.parse(File.read('data/candles/' + 
         'minute_candles_db.json')).transform_keys { |k| k.to_i}
end

def top_extremum(history)
  to_points(history.map { |x| x[1]['max'] }.max)
end

def low_extremum(history)
  to_points(history.map { |x| x[1]['min'] }.min)
end

def amplitude(hash)
  hash["top_extremum"] - hash["low_extremum"]
end

def scale_ratio(hash)
  (hash["image_height"].to_f -
    hash["vertical_padding"] * 2) / hash["amplitude"]
end

def paint_candle(i, settings)
  if settings["history"][i]['start'] < settings["history"][i]['finish']
    @candles.fill_opacity(1)
  else
    @candles.fill_opacity(0)
  end
end

def draw_candle_body(i, nth_candle, settings)
  start  = settings["history"][i]["start"]
  finish = settings["history"][i]["finish"]

  @candles.rectangle(
        nth_candle * settings["density"],
        to_graph(start, settings),

        nth_candle * settings["density"] + settings["thickness"],
        to_graph(finish, settings) + 1,
      )
end

def draw_body_shadows(i, nth_candle, settings)
  start  = settings["history"][i]["start"]
  finish = settings["history"][i]["finish"]
  min    = settings["history"][i]["min"]
  max    = settings["history"][i]["max"]


  high_end = [start, finish].max
  low_end  = [start, finish].min
  middle   = nth_candle * settings["density"] + settings["thickness"] / 2

  if max != high_end
    @candles.line(
      middle,
      to_graph(high_end, settings),

      middle,
      to_graph(max, settings)
    )
  end

  if min != low_end

    @candles.line(
      middle,
      to_graph(low_end, settings) + 1,

      middle,
      to_graph(min, settings)
      )
  end
end

def to_points(rate_value) 
  (rate_value * 10_000).round
end

def to_graph(rate_value, settings)
  (settings["top_extremum"] - to_points(rate_value)) * 
    settings["scale_ratio"] + settings["vertical_padding"]
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
     arr = number.digits.reverse

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