# Flappy Block
# A flappy bird clone in Ruby and Tk
# Kevin McMorrow
# Feb 2014

require 'tk'
require_relative 'sprite'

FPS = 60
RESTART_DELAY = 2000

WIDTH = 640
HEIGHT = 480

BIRD_WIDTH = 40
BIRD_HEIGHT = BIRD_WIDTH
PIPE_WIDTH = 60
PIPE_SPACING = 200

BACKGROUND_COLOR = '#70aaff'
BLOCK_COLOR = '#ffffff'
PIPE_COLOR = '#60ff22'

#GRAVITY = 0.2
#PIPE_SPEED = 4
#GAP_SIZE = 150
#FLAP_STRENGTH = 4

GRAVITY = 0.3
PIPE_SPEED = 5
GAP_SIZE = 150
FLAP_STRENGTH = 6

# The "bird" class
class Bird < Sprite
  attr_accessor :alive
  
  def initialize(canvas, x, y, width, height, color)
    super(canvas, x, y, width, height)
    @canvas_obj = TkcRectangle.new(canvas, x, y, x + width, y + height, 'fill' => color)
    @dy = 0
    @alive = true
  end

  def update
    @dy = @dy + GRAVITY
    move(0, @dy)
  end

  def flap
    if @alive
      @dy = -FLAP_STRENGTH
    end
  end

end

# The obstacles
class Pipe < Sprite
  attr_accessor :passed # bird has travelled past this pipe
  
  def initialize(canvas, x, y, width, height, color)
    super(canvas, x, y, width, height)
    @canvas_obj = TkcRectangle.new(canvas, x, y, x + width, y + height,
                                   'fill' => color)
    canvas.lower(@canvas_obj)
    @passed = false
  end

  def update
    move(-PIPE_SPEED, 0)
  end
end

# Main game class
class Flappy
  def initialize
    root = setup_layout
    bind_events root
  end

  # start the game loop
  def start
    restart
    update
    Tk.mainloop
  end

  private

  def restart
    @running = true
    @canvas.delete('all')
    @bird = Bird.new(@canvas, WIDTH / 3, HEIGHT / 2, BIRD_WIDTH, BIRD_HEIGHT,
                     BLOCK_COLOR)
    @pipes = []
    @score = 0
    create_pipe(WIDTH - 100)
    @score_label = create_score_label
  end
  
  def setup_layout
    root = TkRoot.new do
      title 'Flappy Block'
    end

    @canvas = TkCanvas.new(root) do
      width WIDTH
      height HEIGHT
      background BACKGROUND_COLOR
      pack('side' => 'top')
    end

    root
  end

  def create_score_label
    TkcText.new(@canvas, WIDTH - 10, 5, 'text' => '0',
                'anchor' => 'ne', 'font' => 'sans 24 bold',
                'fill' => '#ffffff')
  end

  def bind_events(root)
    root.bind('KeyPress', proc { @bird.flap })
    root.bind('ButtonPress-1', proc { @bird.flap })
  end

  def update
    Tk.after(1000 / FPS, proc { update })
    if @running
      if @bird.rect[:y2] < HEIGHT
        @bird.update
      else
        @running = false
        Tk.after(RESTART_DELAY, proc { restart })
      end
      if @bird.alive
        @pipes.select! { |pipe| pipe.rect[:x2] > 0 }
        spawn_pipe
        @pipes.each { |pipe| pipe.update }
        check_for_collisions
      end

      @pipes.each { |pipe| pipe.draw }
      @bird.draw

      update_score
    end
  end

  def spawn_pipe
    pipe = @pipes.last
    if pipe && pipe.rect[:x2] < WIDTH - PIPE_SPACING
      create_pipe WIDTH + PIPE_WIDTH / 2
    end
  end

  def create_pipe x
    gap_y = rand(HEIGHT - 2 * GAP_SIZE) + GAP_SIZE
    top_height = gap_y - (GAP_SIZE / 2)
    top_y = top_height / 2
    bottom_height = HEIGHT - gap_y - (GAP_SIZE / 2)
    bottom_y = HEIGHT - (bottom_height / 2)
    @pipes.push Pipe.new(@canvas, x, top_y, PIPE_WIDTH,
                         top_height, PIPE_COLOR)
    @pipes.push Pipe.new(@canvas, x, bottom_y, PIPE_WIDTH,
                         bottom_height, PIPE_COLOR)
  end

  def check_for_collisions
    @pipes.each do |pipe|
      if pipe.overlaps? @bird
        @bird.alive = false
      end
    end
  end

  def update_score
    @bird.alive && @pipes.reject { |pipe| pipe.passed }
      .select { |pipe| pipe.rect[:x2] < @bird.rect[:x1] }
      .each { |pipe| pipe.passed = true; @score += 0.5 }
    @score_label.configure('text' => @score.floor.to_s)
  end
end

# start game
Flappy.new.start
