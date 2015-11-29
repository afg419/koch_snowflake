attr_reader :iteration


def setup
  sketch_title 'Koch Snowflake'
  @k = SnowFlake.new
  @iteration = ARGV[0].to_i
  @perimeter_per_iterations = [["Perimeter for iteration 0:", " #{@k.perimeter}"]]

  @iteration.times do |num|
    @k.iterate
    @perimeter_per_iterations << ["Perimeter for iteration #{num + 1}:", " #{@k.perimeter}"]
  end

  @s = Segment.new(-250,-250,250,-250)
  background 0
  no_stroke
end

def draw
  fill 0, 20
  rect 0, 0, width, height
  translate width / 2, height / 2
  # @s.split.each do |segment|
  #   segment.trace
  # end

  @k.sketch
  fill(255)
  perim = @k.perimeter

  @perimeter_per_iterations.each_with_index do |val, ind|
    text(val.reduce(:+), -130, -295 + (ind+1)*25)
  end
end

def settings
  size 1000, 1000
  smooth
end

class Segment
  attr_reader :start, :finish, :vector, :length, :angle_mod

  def initialize(x0,y0,x1,y1,angle_mod = 1)
    @start = Vec2D.new(x0,y0)
    @finish = Vec2D.new(x1,y1)
    @vector = finish - start
    @length = vector.mag
    @angle_mod = angle_mod
  end

  def trace
    stroke 255
    line start.x, start.y, finish.x, finish.y
  end

  def split
    new_length = length/3
    new_vector = vector/(3.to_f)
    first = Segment.new(start.x, start.y, (start+new_vector).x, (start+new_vector).y, angle_mod)
    last = Segment.new((finish-new_vector).x,(finish-new_vector).y,finish.x,finish.y, angle_mod)
    angled = new_vector.rotate(-PI/3*angle_mod)
    mid_first = Segment.new((start+new_vector).x, (start+new_vector).y, (start+new_vector+angled).x, (start+new_vector+angled).y, angle_mod)
    mid_last = Segment.new((start+new_vector+angled).x, (start+new_vector+angled).y, (finish-new_vector).x, (finish-new_vector).y, angle_mod)
    [first,last,mid_first,mid_last]
  end
end

class SnowFlake
  attr_reader :s01, :s12, :s02, :sides

  def initialize
    @s01 = [Segment.new(-275,-275 - 50,275,-275 - 50)]
    @s12 = [Segment.new(275,-275 - 50,0,(Math.sqrt(3))*275/2.to_f - 85)]
    @s02 = [Segment.new(-275,-275 - 50,0,(Math.sqrt(3))*275/2.to_f - 85,-1)]
    @sides = [s01,s12,s02]
  end

  def sketch
    sides.each do |side|
      side.each do |segment|
        segment.trace
      end
    end
  end

  def iterate
    @sides = sides.map do |side|
      side.map do |segment|
        segment.split
      end.flatten
    end
  end

  def perimeter
    sides.reduce(0) do |perim, side|
      perim + side.reduce(0) do |side_length, segment|
        side_length + segment.length
      end
    end
  end
end
