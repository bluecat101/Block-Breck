# p `echo "aaa"`
# p "hello world"
require 'io/console'
CURSOR_MARK = "5"
EDGE_MARK = "$"
BALL_MARK = "7"

class InOut
  class << self
    def readfile
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

    # def move_cursor(line,row,len,direction) # line,rowは先頭が0
    #   print(line,row,len,"\n")
    #   cursor_line = @@arrangement[line].split('')
    #   cursor_line[row] = CURSOR_MARK
    #   cursor_line[row + len] = "9"
    #   updateFileLine(line,cursor_line.join)
    # end

    def updateFileLine(line,str)
      File.open("input.txt", mode = "r+"){|f|
        (line).times{ 
          f.readline  # 1行空読みする
        }
        f.write(str)
      }
    end
  end
end

class Operation
  def self.move_cursor(direction)
    # InOut.getArrangement

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
  # def x() 
  #   puts x
  #   x 
  # end
  # def y() y end
  def move
    # puts @@y_amount_change[@direction]
    arrangement = InOut.arrangement
    # puts arrangement[@y+@@y_amount_change[@direction]][@x+@@x_amount_change[@direction]]
    # puts(arrangement)
    next_position = Array.new(4){|i|
      case arrangement[@y+@@y_ball_size[i]+@@y_amount_change[@direction]][@x+@@x_ball_size[i]+@@x_amount_change[@direction]]
      when  CURSOR_MARK , EDGE_MARK 
        puts "$ or cursor[#{@y+@@y_ball_size[i]+@@y_amount_change[@direction]},#{@x+@@x_ball_size[i]+@@x_amount_change[@direction]}],#{arrangement[@y+@@y_ball_size[i]+@@y_amount_change[@direction]][@x+@@x_ball_size[i]+@@x_amount_change[@direction]]}"
        0
      when "9","5"
        puts "空白"
        1
      else 
        puts "block[#{@y+@@y_ball_size[i]+@@y_amount_change[@direction]},#{@x+@@x_ball_size[i]+@@x_amount_change[@direction]}],#{arrangement[@y+@@y_ball_size[i]+@@y_amount_change[@direction]][@x+@@x_ball_size[i]+@@x_amount_change[@direction]]}"
        # 消す操作
        0
      end
      # @@y_amount_change[@direction]
      # puts "aaa"
    }
    if(next_position.count(1) == 4)
      puts("")
      ball_line_now = arrangement[@y]
      ball_line_now[@x] = "9"
      ball_line_now[@x+1] = "9"
      InOut.updateFileLine(@y,ball_line_now)
      # end
      @x += @@x_amount_change[@direction]
      @y += @@y_amount_change[@direction]
      ball_line_next = arrangement[@y]
      ball_line_next[@x] = BALL_MARK
      ball_line_next[@x+1] = BALL_MARK
      InOut.updateFileLine(@y,ball_line_next)
    else
      # next_position.select{|status| status==0}.sample
      @direction = reflect()
    end
    # @direction = reflect()
    # @direction = reflect()



      
  end
  def reflect
    # puts ("[direction]#@direction")
    p Array.new(3){|i| (@direction+i+3)%8}.sample
    
  end
end

ball = Ball.new()
InOut.readfile()
# Operation.move_cursor("C")
# exit
while (c = STDIN.getch) != "\C-c"
  if(c == "\e" && (_c = STDIN.getch) == "[")
    second_c = STDIN.getch
    if(second_c == "C" || second_c == "D")
      Operation.move_cursor(second_c)
    end
  elsif (c == "n")
    ball.move
  else
    print c
  end
  # 14.times{print"\e[A"}
  InOut.readfile()
end
puts("end break brock")
