require_relative 'methods.rb'
require 'json'

dollar = 75.0
euro   = 82.0

rate = {}

1589749200.step(1589752200, 60) { |i|
  minute_history = []
  60.times {
    dollar = (dollar + rand(-0.01..0.01)).round(4)
    euro   = (euro   + rand(-0.01..0.01)).round(4)
    minute_history << (euro / dollar).round(4)  
  }
  rate[i] = {
    'start'  => minute_history[0],
    'finish' => minute_history[-1],
    'max'    => minute_history.max,
    'min'    => minute_history.min
  }
}
if Dir.exist?('data')
  unless Dir.exist?('data/candles')
    Dir.chdir('data') { Dir.mkdir('candles') }
  end 
else 
  Dir.mkdir('data')
  Dir.chdir('data') { Dir.mkdir('candles') }
end   

File.write('data/candles/minute_candles_db.json', rate.to_json)
