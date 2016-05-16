require_relative 'color'

class Colors
  def initialize(min, max, min_color, max_color)
    @min = min
    @max = max

    @c_min = Color.new.from_hex(min_color)
    @c_max = Color.new.from_hex(max_color)
  end

  def at(value)
    return @c_min if value <= @min
    return @c_max if value >= @max

    a = @c_min
    b = @c_max
    t = (value - @min) / (@max - @min).to_f

    if a.h < b.h
      a, b = b, a
      t = 1 - t
    end
    d = b.h - a.h

    if d > 0.5
      h = (a.h + 1 + t * (b.h - a.h - 1)) % 1
    else
      h = a.h + t * d
    end

    s = a.s + t * (b.s - a.s)
    v = a.v + t * (b.v - a.v)

    Color.new.from_hsv(h, s, v)
  end
end
