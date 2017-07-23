require 'io/console'

##
# Flappy Bird
class FlappyBird
  LED_WIDTH = 16
  LED_HEIGHT = 32
  LED_DEPTH = 8
  BIRD = [
    [0xFFFF00, 0x000000, 0xFFFFFF, 0xFFFFFF, 0xFFFFFF, 0x000000],
    [0xFFFF00, 0xFFFF00, 0xFFFFFF, 0xFFFFFF, 0x000000, 0xFFFFFF],
    [0xFFFF00, 0xFFFF00, 0xFFFF00, 0xFFFF00, 0xFFFFFF, 0xFFFFFF],
    [0x000000, 0xFFFF00, 0xFFFF00, 0xFF0000, 0xFF0000, 0xFF0000]
  ].freeze

  def initialize(led)
    @led = led
    @led.ShowMotioningText1('321')
    @game_over = false
    @blockz = LED_DEPTH - 1
    @pos = { x: (LED_WIDTH - BIRD.first.size) / 2, y: LED_HEIGHT / 2 }
    @ana = new_ana
    @mutex = Mutex.new
    th = []
    th.push Thread.new { key_thread until @game_over }
    th.push Thread.new { block_thread until @game_over }
    main_thread until @game_over
    th.join
  end

  def main_thread
    @led.Clear
    set_block
    set_bird
    @led.Show
    @led.Wait(10)
  end

  def key_thread
    key = STDIN.getch.ord
    exit 0 if [0x03, 0x1A].any? { |a| a == key }
  end

  def block_thread
    @ana = new_ana if @blockz.zero?
    @blockz = @blockz.zero? ? LED_DEPTH - 1 : @blockz - 1
    sleep(0.2)
  end

  def new_ana
    ana = BIRD.size + 4
    r = rand(LED_HEIGHT - ana)
    (r...(r + ana))
  end

  def set_block
    (0...LED_HEIGHT).each do |y|
      next if @ana.any? { |a| a == y }
      (0...LED_WIDTH).each do |x|
        @led.SetLed(x, y, @blockz, 0x00FF00)
      end
    end
  end

  def set_bird
    (0...BIRD.size).each do |y|
      (0...BIRD.first.size).each do |x|
        @led.SetLed(x + @pos[:x], y + @pos[:y], 0, BIRD[y][x])
      end
    end
  end
end

def execute(led)
  loop { FlappyBird.new(led) }
end