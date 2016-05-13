#!/usr/bin/env ruby

# DOC:
# Brightnes: 0 - 255
# Color: (R, G, B) 0 - 255

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'ws2812'

# Init
n = 24 # num leds
ws = Ws2812::Basic.new(n, 18) # +n+ leds at pin 18, using defaults
ws.open

ws.brightness = 128

pos = 0

while
  color = [0, 0, 0]
  
  (0...24).each do |i|
    color[pos] = i*10
  
    ws[i] = Ws2812::Color.new(color[0], color[1], color[2])
    ws.show
    sleep 0.25
  end

  pos = (pos + 1) % 3
  color = [0, 0, 0]
end

abort

# Some constans for temperature-color handling
min_t = 22
max_t = 26
temp_steps = 10
step = (max_t- min_t) / temp_steps
# TODO: color tresholds: 0xFF00FF -> 0x0000FF -> 0x00FFFF -> 0x00FF00 -> 0xFFFF00 -> 0xFF0000


