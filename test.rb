# p `echo "aaa"`
# p "hello world"
require 'io/console'
CURSOR_MARK = "5"

class InOut
  def self.readfile
    arrangement = self.getArrangement()
    color_status = 9
    arrangement.each{|line|
      line.split('').each{|c|
        if (c == '$')
          color_status = 9
          print("\x1b[%4#{color_status}m");
          print("$");
        elsif(c == "\n")
          puts ''
        else
          color_status = c.to_i
          print("\x1b[%4#{color_status}m ");
        end
      
      }
    }
  end  
  def self.getArrangement
    File.open("input.txt",mode="rt"){|f|
      f.readlines
    }
  end

  def self.move_cursor(line,row,len,direction) # line,rowは先頭が0
    print(line,row,len,"\n")
    arrangement = self.getArrangement()
    cursor_line = arrangement[line].split('')
    cursor_line[row] = CURSOR_MARK
    cursor_line[row + len] = "9"
    self.updateFileLine(line,cursor_line.join)
  end

  def self.updateFileLine(line,str)
    File.open("input.txt", mode = "r+"){|f|
      (line).times{ 
        f.readline  # 1行空読みする
      }
      f.write(str)
    }
  end
end

class Operation
  

  
  def self.move_cursor(direction)
    arrangement = InOut.getArrangement

    arrangement.each_with_index{|line,i|
      if((len = line.count(CURSOR_MARK))!=0)
        position = line.index(CURSOR_MARK)
        cursor_line = line
        is_rightEdge = line[position + len ] == "$"
        is_leftEdge  = line[position - 1] == "$"
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





# print("adsf")
# print "\r11"
# exit
InOut.readfile()
# Operation.move_cursor("C")
# exit
while (c = STDIN.getch) != "\C-c"
  
  if(c == "\e" && (_c = STDIN.getch) == "[")
    second_c = STDIN.getch
    if(second_c == "C" || second_c == "D")
      Operation.move_cursor(second_c)
    end
  else
    print c
  end
  14.times{print"\e[A"}
  InOut.readfile()
end
puts("end break brock")
