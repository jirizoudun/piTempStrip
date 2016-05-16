class Color
  attr_reader :r, :g, :b, :h, :s, :v

  private
  def initialize
    @r = 0
    @g = 0
    @b = 0
    @h = 0
    @s = 0
    @v = 0
  end

  public
  def from_hex(hex)
    @r = ((hex & 0xFF0000) >> 16) / 255.0
    @g = ((hex & 0x00FF00) >>  8) / 255.0
    @b = ((hex & 0x0000FF)      ) / 255.0
    compute_hsv
    self
  end

  def from_hsv(h, s, v)
    @h = h
    @s = s
    @v = v
    compute_rgb
    self
  end

  def rgb
    [@r, @g, @b]
  end

  def rgb2
    [(@r * 255).to_i, (@g * 255).to_i, (@b * 255).to_i]
  end

  def hsv
    [@h, @s, @v]
  end

  def hsv2
    [(@h * 360).to_i, (@s * 100).to_i, (@v * 100).to_i]
  end

  private
  def compute_hsv
    c = [@r, @g, @b].minmax

    h = 0
    s = 0
    v = c[1]
    delta = v - c[0]

    if delta != 0
      h = 60 * begin
        if v == @r
          ((@g - @b) / delta) % 6
        elsif v == @g
          ((@b - @r) / delta) + 2
        elsif v == @b
          ((@r - @g) / delta) + 4
        end
       end
    end

    if v != 0
      s = delta / v
    end

    @h = h / 360
    @s = s
    @v = v
  end

  def compute_rgb
    c = @v * @s
    h = @h * 360
    x = c * (1 - (((h / 60) % 2) - 1).abs)
    m = v - c

    if h < 60
      r, g, b = c, x, 0
    elsif h < 120
      r, g, b = x, c, 0
    elsif h < 180
      r, g, b = 0, c, x
    elsif h < 240
      r, g, b = 0, x, c
    elsif h < 300
      r, g, b = x, 0, c
    elsif h < 360
      r, g, b = c, 0, x
    end

    @r = r + m
    @g = g + m
    @b = b + m
  end
end
