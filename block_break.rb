# p `echo "aaa"`
# p "hello world"
require 'io/console'
require 'timeout'

CURSOR_MARK = "5"
EDGE_MARK = "$"
BALL_MARK = "7"

class InOut
  class << self
    def readFile
      @arrangement = arrangement()
      color_status = 9
      @arrangement.each{|line|
        line.split('').each{|c|
          if (c == EDGE_MARK)
            color_status = 9
            print("\x1b[%4#{color_status}m");
            print(EDGE_MARK);
          elsif(c == "\n")
            puts ''
          else
            color_status = c.to_i
            print("\x1b[%4#{color_status}m ");
          end
        
        }
      }
    end

    def arrangement() 
      File.open("input.txt",mode="rt"){|f|
        f.readlines
      }
    end
    def updateFileLine(line,str)
      File.open("input.txt", mode = "r+"){|f|
        (line).times{ 
          f.readline  # 1行空読みする
        }
        f.write(str)
      }
    end

    def updateFileBlock(line,row)
      File.open("input.txt", mode = "r+"){|f|
        (line).times{ 
          f.readline  # 1行空読みする
        }
        f.seek(row,IO::SEEK_CUR)
        f.write("9")
      }
    end
  end
end

class Cursor
  def self.move(direction)
    InOut.arrangement.each_with_index{|line,i|
      if((len = line.count(CURSOR_MARK))!=0)
        position = line.index(CURSOR_MARK)
        cursor_line = line
        is_rightEdge = line[position + len ] == EDGE_MARK
        is_leftEdge  = line[position - 1] == EDGE_MARK
        if(direction == "C" && !is_rightEdge)
          cursor_line[position] = "9"
          cursor_line[position + len] = CURSOR_MARK
          InOut.updateFileLine(i,cursor_line)
        elsif(direction == "D" && !is_leftEdge)
          cursor_line[position-1] = CURSOR_MARK
          cursor_line[position+len-1] = "9"
          InOut.updateFileLine(i,cursor_line)
        end    
      end
    }
  end
end

class Ball
  @@x_amount_change = {0 => 0, 1 => 1, 2 => 1, 3 => 1, 4 => 0, 5 => -1, 6 => -1, 7 => -1}
  @@y_amount_change = {0 => -1, 1 => -1, 2 => 0, 3 => 1, 4 => 1, 5 => 1, 6 => 0, 7 => -1}
  @@x_ball_size =[0,1,0,1]
  @@y_ball_size =[0,0,0,0]
  @x = nil
  @y = nil
  @direction = nil # 0-7
  def initialize()
    InOut.arrangement.each_with_index{|line,i|
      if(position = line.index(BALL_MARK))
        @x = position
        @y = i
      end
    }
    @direction = 4
  end
  def move
    arrangement = InOut.arrangement
    next_position = Array.new(4){|i|
      case arrangement[@y+@@y_ball_size[i]+@@y_amount_change[@direction]][@x+@@x_ball_size[i]+@@x_amount_change[@direction]]
      when  CURSOR_MARK , EDGE_MARK then 0
      when "9",BALL_MARK then 1
      else 
        InOut.updateFileBlock(@y+@@y_ball_size[i]+@@y_amount_change[@direction],@x+@@x_ball_size[i]+@@x_amount_change[@direction])
        0
      end
    }
    if(next_position.count(1) == 4)
      ball_line_now = arrangement[@y]
      ball_line_now[@x] = "9"
      ball_line_now[@x+1] = "9"
      InOut.updateFileLine(@y,ball_line_now)
      @x += @@x_amount_change[@direction]
      @y += @@y_amount_change[@direction]
      ball_line_next = arrangement[@y]
      ball_line_next[@x] = BALL_MARK
      ball_line_next[@x+1] = BALL_MARK
      InOut.updateFileLine(@y,ball_line_next)
    else
      @direction = reflect()
    end
  end
  def reflect
    Array.new(3){|i| (@direction+i+3)%8}.sample
  end
end

ball = Ball.new()
count = 0
InOut.readFile()
while true
  begin
    Timeout.timeout(0.1) do
      ball.move
      14.times{print"\e[A"}
      InOut.readFile()
      c = STDIN.getch
      if(c=="\C-c")
        exit
      elsif(c == "\e" && (_c = STDIN.getch) == "[")
        second_c = STDIN.getch
        if(second_c == "C" || second_c == "D")
          Cursor.move(second_c)
        end
      end
      14.times{print"\e[A"}
      InOut.readFile()
    end
  rescue Timeout::Error
  end
end
puts("end break brock")

