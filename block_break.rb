require 'io/console'
require 'timeout'

BAR_MARK = "5" # 棒のマーク
EDGE_MARK = "$"   # 境界線のマーク
BALL_MARK = "7"   # ボールのマーク
BACKGROUND_MARK = "9"   # ボールのマーク
# FILE_LINE_SIZE 下で定義する
class InOut # FILE操作のクラス
  class << self
    def readFile # FILEから読み込み、文字に合わせて色を出力する関数
      arrangement = arrangement() # 配列の取得
      current_color = BACKGROUND_MARK # 現在の色に背景色をセット
      arrangement.each{|line| # 1行ずつロード
        line.chars{|c|        # 1文字ずつロード
          if (c == EDGE_MARK) # 境界線のマークなら
            current_color = BACKGROUND_MARK                # current_colorの更新 
            print("\x1b[%4#{current_color}m#{EDGE_MARK}"); # マークを出力
          elsif(c == "\n") # 改行コードなら
            puts ''        #　改行
          else # 棒、ボール、ブロックの時
            current_color = c                   # current_colorの更新
            print("\x1b[%4#{current_color}m "); #　空白を出力
          end
        }
      }
    end

    def arrangement() # FILEを読み込む, 戻り値: FILEの配列
      File.open("input.txt",mode="rt"){|f|
        f.readlines   # 各行を読み込む
      }
    end

    def updateFileLine(line,str) # FILEの1行を更新する, 引数: 行数, 書き換える文字列
      File.open("input.txt", mode = "r+"){|f| 
        (line).times{ #　目的の行まで繰り返す
          f.readline  # 1行空読み
        }
        f.write(str)  # 上書き
      }
    end

    def updateFileBlock(line,row) # FILEの1文字を消す, 引数: 行数, 列数
      File.open("input.txt", mode = "r+"){|f|
        (line).times{ 
          f.readline  # 1行空読みする
        }
        f.seek(row,IO::SEEK_CUR) # 目的の列まで移動する
        f.write(BACKGROUND_MARK) # 背景色で上書き
      }
    end
  end
end

class Bar # 棒
  def self.move(direction) # 棒を動かす関数
    InOut.arrangement.each_with_index{|line,i| # 配列を読み込む
      if((len = line.count(BAR_MARK)) != 0) # 棒の存在する行の時
        position = line.index(BAR_MARK) # 棒が何列目にあるかを取得
        bar_line = line                 # 棒のある1行を格納
        is_rightEdge = line[position + len ] != BACKGROUND_MARK # 右端かを取得
        is_leftEdge  = line[position - 1]    != BACKGROUND_MARK  # 左端かを取得
        if(direction == "C" && !is_rightEdge)  # 右が入力されてかつ右端でないなら
          bar_line[position] = BACKGROUND_MARK # 棒の一番左を背景色に
          bar_line[position + len] = BAR_MARK  # 棒の一番右にさらにもう1文字右に棒を追加
          InOut.updateFileLine(i,bar_line)     # 更新
        elsif(direction == "D" && !is_leftEdge)      # 左が入力されてかつ左端でないなら
          bar_line[position-1] = BAR_MARK            # 棒の一番左のさらにもう1文字左に棒を追加
          bar_line[position+len-1] = BACKGROUND_MARK # 棒の一番右を背景色に
          InOut.updateFileLine(i,bar_line)           # 更新
        end    
      end
    }
  end
end

class Ball # ボール
  ##
  # directionの方向は全方位を8等分し、12時の方向を0として時計回りに1ずつ大きくする
  # 現在のボールの大きさはx = 2, y = 1としている
  # ボールの大きさの順番は左上,右上,左下,右下の順に考える
  @@x_amount_change = {0 => 0, 1 => 1, 2 => 1, 3 => 1, 4 => 0, 5 => -1, 6 => -1, 7 => -1} # x軸に対する方向とボールの変化量
  @@y_amount_change = {0 => -1, 1 => -1, 2 => 0, 3 => 1, 4 => 1, 5 => 1, 6 => 0, 7 => -1} # y軸に対する方向とボールの変化量
  @@x_ball_size =[0,1,0,1] # x軸に対する基準からのボールの大きさ
  @@y_ball_size =[0,0,0,0] # y軸に対する基準からのボールの大きさ
  @x = nil # 現在のボールのx座標
  @y = nil # 現在のボールのy座標
  @direction = nil # ボールの方向0-7の8等分で規定
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
    arrangement = InOut.arrangement # 配列を読み込む
    # 各ボールの位置に対して次動いた際の位置がどこに移動するのかを考える
    next_position = Array.new(2){|i| # ボールの大きさだけ繰り返す
      # 次の位置をcaseに当てる
      case arrangement[@y+@@y_ball_size[i]+@@y_amount_change[@direction]][@x+@@x_ball_size[i]+@@x_amount_change[@direction]]
      when  BAR_MARK , EDGE_MARK then 0 # 壁か棒がある
      when BACKGROUND_MARK,BALL_MARK then 1 # ボールか何もない
      else # ブロックがある
        # ブロックの削除
        InOut.updateFileBlock(@y+@@y_ball_size[i]+@@y_amount_change[@direction],@x+@@x_ball_size[i]+@@x_amount_change[@direction])
        0
      end
    }
    # 次の１の結果を踏まえて移動するかを決める
    if(next_position.count(1) == 2) # 移動する時
      ball_line_now = arrangement[@y]        # 移動前のボールの行を取得
      ball_line_now[@x] = BACKGROUND_MARK    # ボールを消す
      ball_line_now[@x+1] = BACKGROUND_MARK  # ボールを消す
      InOut.updateFileLine(@y,ball_line_now) # 更新
      @x += @@x_amount_change[@direction] # x座標を更新する
      @y += @@y_amount_change[@direction] # y座標を更新する
      ball_line_next = arrangement[@y]    # 移動後のボールの行を取得
      ball_line_next[@x] = BALL_MARK      # ボールを表示する
      ball_line_next[@x+1] = BALL_MARK    # ボールを表示する
      InOut.updateFileLine(@y,ball_line_next) # 更新
    else # 障害物(壁,棒,ブロック)があった時
      @direction = reflect() # 方向を変える
    end
  end
  def reflect # 方向を変える関数
    Array.new(3){|i| (@direction+i+3)%8}.sample # 反対方向の3方向からランダムに選ぶ
  end
end

FILE_LINE_SIZE = (InOut.arrangement()).count # FILEの行数を取得(ここでないと、InOutのクラスメソッドが使用できない)
ball = Ball.new() # オブジェクト生成
InOut.readFile()  # 画面の表示
while true #　Ctrl+cが押されるまで続ける
  begin
    Timeout.timeout(0.2) do # timeoutを設定,これにより、入力とボールの移動を可能にしている
      ball.move        # ボールを動かす
      (FILE_LINE_SIZE-1).times{print"\e[A"} # カーソルを一番上に持っていく
      InOut.readFile() # 画面を更新 
      c = STDIN.getch  # 入力待ち(timeoutがないとブロッキングされてしまう)
      if(c=="\C-c")    # やめる時
        exit
      elsif(c == "\e" && (_c = STDIN.getch) == "[") # 矢印キーが押された時
        second_c = STDIN.getch                 # もう1文字取得
        if(second_c == "C" || second_c == "D") # 左か右の時
          Bar.move(second_c)                   # 棒を動かす
        end
      end
      (FILE_LINE_SIZE-1).times{print"\e[A"} # カーソルを一番上に持っていく
      InOut.readFile()                      # 画面の更新
      while true
        _ = STDIN.getch
      end
      sleep
    end
  rescue Timeout::Error
  end
end
puts("end break brock") # ゲームが終了したことを知らせる

