require 'io/console'
require 'timeout'
input = nil
while true
  begin
    Timeout.timeout(0.1) do
      puts ("---")      
      input = STDIN.getch
      # input = Curses.getch
      puts ("your hit is #{input}")
      if(input=="\C-c")
        exit
      end
      # sleep
    end
  rescue Timeout::Error
    # ignore
  end
end