class ProgressBar

    # 定数定義 
    EDGE = "|"
    SCALE = "---------+" * 4
    BAR = (EDGE + SCALE).chop + EDGE    # プログレスバーのベース文字列
    DONE = "="                          # 済み記号
    ARROW = ">"                         # 済み記号の先端

    #
    # initialize    初期化
    #   引数
    #       title   :   プログレスバーのタイトル名
    #       total   :   プログレスバーの 100%の値
    #
    def initialize(title, total)
        # インスタンス変数　定義
        @title = title      # 進捗表示する処理名（フォルダー名とか渡す）
        @total = total      # 100% 時の値（単位は何でもいい。）
        @done = 0           # 完了した値
        @line = ""          # 表示する内容
    end
    
    #
    # show 
    # プログレスバーの表示更新
    #   引数
    #       info    :   バーに表示する情報文字列
    #       size    :   進捗する値   
    #
    def show(info, size)

        # 処理したファイルサイズを加算し、進捗割合を計算
        @done += size        
        progress = get_progress(@total, @done)

        @line = BAR.dup     # BAR の内容を複製（こうしないと BAR の値が変わってしまう。。）

        if progress >= 100 then                 # 進捗が 100% 以上の場合
            @line[1..-2] = DONE*(BAR.length-2)  # 両端を除く全てを DONE 記号で埋める。
        else
            tmp = EDGE + (DONE*(progress*(SCALE.length)/100).floor).chop + ARROW     # 進捗部分を生成して、
            @line[0..tmp.length-1] = tmp                            # 進捗部分を置き換える。
        end
        
        # 情報表示
        print "\r" + " "*BAR*2
        print "\r" + sprintf("%s %s %s%% (%s/%s) %s...", @title[0,10], @line, progress, get_size_str(@done), get_size_str(@total), info[0,5] )
    end
    
    # 進捗状態をリセットする。
    def reset
        @done = 0
    end

    private

    #
    # 進捗割合を取得する。
    def get_progress(total, done)
        if done <= 0 then return 0 end          # done が 0 以下の場合は、0 を返す。
        if total <= 0 then return 100 end       # total が 0 以下 : 100% として返す。
        if total < done then return 101 end     # total が done よりも小さい : 101% として返す。

        return ((done*100)/total).round     # 計算して返す。値は四捨五入で返す。
    end

    # ファイルサイズ文字列を返す。(size は、バイト数で来ることを想定)
    def get_size_str(size)

        unit = ["Bytes", "KiB", "MiB", "Gib"]
        block = 1024

        for n in 0..3 do
            if size.between?(block**n, block**(n+1)) then
                return ((size/block**n).floor).to_s + unit[n]
            end
        end

        # どの単位にも合致しない場合（TiB以上か、負数）は、そのまま Bytes で返す。
        return size + "Bytes"

    end

end

