#!/usr/bin/env ruby

# DOC:
# Brightnes: 0 - 255
# Color: (R, G, B) 0 - 255

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'ws2812'
require_relative 'client'
require_relative 'colors'

n = 24 # num leds

class NeoPrinter
  def initialize(min_temperature, max_temperature)
    @colors = Colors.new(min_temperature, max_temperature, 0x0000FF, 0xFF0000)
    neopixel # Init neopixel strip.
  end

  def neopixel
    @strip = Ws2812::Basic.new(24, 18) # 24 leds at pin 18, using defaults
    @strip.open

    @strip.brightness = 64
  end

  def show_values(values)
    return unless values.kind_of?(Array)
    return unless values.count <= 24

    values.each_with_index do |temp, i|
      color = @colors.at temp
      @strip[i] = Ws2812::Color.new(color.rgb2[0], color.rgb2[1], color.rgb2[2])
    end

    @strip.show
  end

  private :neopixel
end

np = NeoPrinter.new(25, 32)
client = Client.new('living-room', 'localhost', 23457)
while
  values = client.read(24)
  np.show_values(values.map {|x| x.to_f})

  sleep 1
end

client.close



