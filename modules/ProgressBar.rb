class ProgressBar

    # 定数定義 
    EDGE = "|".freeze                   # バーの両端
    SCALE = ("---------+" * 4).freeze   # バーの目盛り部分
    BAR = ((EDGE + SCALE).chop + EDGE).freeze   # バーのベース文字列
    DONE = "=".freeze                   # 済み記号
    ARROW = ">".freeze                  # 済み記号の先端

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
        @showed_length = 0  # 直前に表示した文字列の長さ（上書きの際に使用する。）
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

        bar = BAR.dup     # BAR の内容を複製（こうしないと BAR の値が変わってしまう。。）

        if progress >= 100 then                 # 進捗が 100% 以上の場合
            bar[1..-2] = DONE*(BAR.length-2)  # 両端を除く全てを DONE 記号で埋める。
        else
            tmp = EDGE + (DONE*(progress*(SCALE.length)/100).floor).chop + ARROW    # 進捗部分を生成して、
            bar[0..tmp.length-1] = tmp                                            # 進捗部分を置き換える。
        end

        # 前回表示した行を消去
        print "\r".ljust(@showed_length)

        # 情報表示
        line = "\r" + sprintf("%s %s %s%% (%s/%s) %s...", @title[0,10], bar, progress, get_size_str(@done), get_size_str(@total), info[0,10])
        print line
        @showed_length = line.length
    end
    
    #
    # reset
    # 進捗をリセットする。
    #
    def reset
        @done = 0
        @showed_length = 0
    end

    private

    #
    # get_progress
    # 進捗度を割合計算し、100分率(%)で返す。
    #   引数
    #       total   :   100% となるサイズ
    #       done    :   実行済みのサイズ
    #   戻り値
    #       進捗度（100分率の整数値。端数は四捨五入）
    #
    def get_progress(total, done)
        if done <= 0    then return 0   end     # done が 0 以下の場合は、0 を返す。
        if total <= 0   then return 100 end     # total が 0 以下 : 100% として返す。
        if total < done then return 101 end     # total が done よりも小さい : 101% として返す。

        return ((done*100)/total).round     # 計算して返す。値は四捨五入で返す。
    end

    #
    # get_size_str      バイト数を KiB, MiB, GiB のうち、最適な単位に変換して返す。
    #   引数
    #       bytes   :   バイト数
    #   戻り値
    #       最適な単位にしたバイト数と単位を付与した文字列
    #
    def get_size_str(bytes)
        unit = ["Bytes", "KiB", "MiB", "GiB"]
        block = 1024

        # KiB, MiB, GiB かどうかを判定する。
        for n in 1..3 do
            if bytes.between?(block**n, block**(n+1)) then
                return ((bytes/block**n).floor).to_s + unit[n]
            end
        end

        # どの単位にも合致しない場合は、そのまま Bytes で返す。
        return bytes.to_s + unit[0]
    end
end
