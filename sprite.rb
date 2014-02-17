# Sprite class
class Sprite
  attr_reader :rect

  def initialize(canvas, x, y, width, height)
    @canvas = canvas
    @rect = {
      x1: x - width / 2,
      y1: y - height / 2,
      x2: x + width / 2,
      y2: y + height / 2
    }
  end

  def update
    puts 'sprite update not implemented'
  end

  def draw
    if @canvas_obj
      @canvas.coords(@canvas_obj, @rect[:x1], @rect[:y1],
                     @rect[:x2], @rect[:y2])
    else
      puts 'WARNING: No canvas object set'
    end
  end

  def overlaps?(other)
    @rect[:x1] < other.rect[:x2] &&
      @rect[:x2] > other.rect[:x1] &&
      @rect[:y1] < other.rect[:y2] &&
      @rect[:y2] > other.rect[:y1]
  end

  def move(dx, dy)
    @rect[:x1] += dx
    @rect[:x2] += dx
    @rect[:y1] += dy
    @rect[:y2] += dy
  end

  def set_position(x, y)
    @rect = {
      x1: x - width / 2,
      y1: y - height / 2,
      x2: x + width / 2,
      y2: y + height / 2
    }
  end

  def width
    @rect[:x2] - @rect[:x1]
  end

  def height
    @rect[:y2] - @rect[:y1]
  end

  def mid_point
    {
      x: @rect[:x1] + width / 2,
      y: @rect[:y1] + height / 2
    }
  end
end
