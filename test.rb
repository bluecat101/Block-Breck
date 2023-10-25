require 'io/console'

# require 'curses'

# Curses.timeout=(3)
# offset = 0
# length = 13
# buffer = IO::Buffer.new(length)
# while true
while true
    # sleep 1
    # read_string = ''
    puts("adf")
    begin
      puts STDIN.read_nonblock(10)
    # when 
      # p "ok"
    rescue IO::EAGAINWaitReadable
      # p result
    end
    # 最大でbuffer.size-offset(つまりバッファの残り分)を取り出し、read_stringに上書きする。
    # 最低は決まっていない。１バイトでも読み出せるものがあればブロックせずにそれを読み出す。
    # See: https://docs.ruby-lang.org/ja/latest/method/IO/i/readpartial.html
    # STDIN.read_partial(buffer.size-offset, read_string)
    # # bufferの中のoffsetバイト目以降に、read_stringを書き出す。
    # offset += buffer.set_string(read_string, offset)
end

# require 'Win32API'
# kbhit = Win32API.new('msvcrt','_kbhit',[],'l')

# print '続行するには何かキーを押してください'
# while true
#    if kbhit.call != 0
#       break
#    end
# end
# puts "\nキーが押されました"