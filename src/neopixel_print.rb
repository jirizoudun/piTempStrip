#!/usr/bin/env ruby

# DOC:
# Brightnes: 0 - 255
# Color: (R, G, B) 0 - 255

$:.unshift(File.expand_path('../../lib', __FILE__))
require 'ws2812'
require_relative 'client'

n = 24 # num leds

class NeoPrinter
  def initialize(min_temperature, max_temperature)
    @min_t = min_temperature
    @max_t = max_temperature
    @steps = 10
    @temp_step = (@max_t - @min_t) / @steps.to_f
    @color_tresholds = [Ws2812::Color.new(0xFF, 0, 0xFF),
                        Ws2812::Color.new(0x7F, 0, 0xFF),
                        Ws2812::Color.new(0, 0, 0xFF),
                        Ws2812::Color.new(0, 0x80, 0xFF),
                        Ws2812::Color.new(0, 0xFF, 0xFF),
                        Ws2812::Color.new(0, 0xFF, 0x7F),
                        Ws2812::Color.new(0, 0xFF, 0),
                        Ws2812::Color.new(0x80, 0xFF, 0),
                        Ws2812::Color.new(0xFF, 0xFF, 0),
                        Ws2812::Color.new(0xFF, 0x7F, 0),
                        Ws2812::Color.new(0xFF, 0, 0)]

    @temp_tresholds = (0..@steps).map { |i| @min_t + i*@temp_step }
    
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

    temp_colors = values.map do |value|
      if(value < @max_t)
        @color_tresholds[@temp_tresholds.find_index {|x| value < x}]
      else
        @color_tresholds[@steps]
      end
    end

    temp_colors.each.with_index do |x, i|
      @strip[i] = x
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



