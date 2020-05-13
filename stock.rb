require "rmagick"

graph = {}

start = 360 + rand(-100..100)


70.times { |i| 
  graph[i] = {
    "start"  => start,
    "finish" => start + rand(-50..50),
    "max"    => start - rand(0..75),
    "min"    => start + rand(0..75)
  }

  start = graph[i]["finish"]
}

p graph




canvas = Magick::ImageList.new
canvas.new_image(1280, 720, Magick::HatchFill.new('white', 'grey90', 10))

dansity   = 7 # Коэффициент плотности японских свечей
thickness = 4 # Толщина свечи

candle = Magick::Draw.new
candle.stroke('green')
candle.fill('green')
candle.stroke_width(1)

70.times { |i|
  if graph[i]["start"] < graph[i]["finish"]
    candle.fill_opacity(0)
  else
    candle.fill_opacity(1)
  end

  candle.rectangle(
    i * dansity, graph[i]["start"], 
    i * dansity + thickness, graph[i]["finish"]
  )

  high_end      = [graph[i]["start"], graph[i]["finish"]].min
  low_end       = [graph[i]["start"], graph[i]["finish"]].max
  candle_center = i * dansity + thickness/2

  if graph[i]["max"] < high_end
    candle.line( 
      candle_center, high_end, 
      candle_center, graph[i]["max"]
    )
  end

  if graph[i]["min"] > low_end
    candle.line( 
      candle_center, low_end, 
      candle_center, graph[i]["min"]
    )
  end
}

candle.draw(canvas)
canvas.write('test.jpg')
puts "Готово, хозяин!"