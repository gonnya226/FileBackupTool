class ProgressBar

    # 表示フォーマット用の文字列 
    BAR = ("|" + ("-"*9 + "+")*5).chop + "|"    # プログレスバーのベース文字列（固定50文字分、1文字2%）
    DONE = "="                                  # 済み記号
    ARROW = ">"                                 # 済み記号の先端
    
    ### 処理中情報の表示（ファイル/フォルダー名）
            ### 割合表示の表示形式
                #### 達成分サイズ、未達分サイズ、割合　の３つを表示？

    # プログレスバーの初期化
    #   total の値を受け取って、初期値とする。
    def initialize(name, total)

        # インスタンス変数
        @total = total      # 100% 時の値（単位はfilesizeでもファイル個数でも何でもいい。）
        @name = name        # 進捗表示する処理名（フォルダー名とか渡す）
        @progress = 0       # 進捗（0% ～ 100%）
        @done = 0           # 完了した値
        @line = ""          # 表示する内容
    end
    
    # プログレスバーの表示更新
    def show(info, filesize)
        
        # 処理したファイルサイズを加算し、進捗割合を計算
        @done += filesize        
        getProgress

        @line = BAR.dup     # BAR の内容を複製（こうしないと BAR の値が変わってしまう。。）

        if @progress < 2 then
            # 進捗無し。何もしない。
        elsif @progress >= 100 then
            @line[1..-2] = DONE*(BAR.length-2)  # 両端を除く全てを DONE 記号で埋める。
        else
            tmp = "|" + (DONE*(@progress/2).floor).chop + ARROW     # 進捗部分を生成
            @line[0..tmp.length-1] = tmp                            # 進捗部分を置き換える。
        end
        
        # 情報表示
        print sprintf("\r%-10s (%s/%s) %s %sをコピー中", @name, getFilesizeString(@done), getFilesizeString(@total), @line, info )

    end
    
    # 進捗状態をリセットする。
    def reset
        @progress = 0
        @done = 0
    end

    private

    # 進捗割合を取得する。
    def getProgress
        if @total <= 0 then
            # total が 0 以下の値：常に100% として返す。
            @progress = 100
        elsif @total < @done
            # total が done よりも小さい：101% として返す。
            @progress = 101
        else
            # それ以外の場合は、計算して返す。値は四捨五入で返す。
            @progress = ((@done*100)/@total).round
        end
    end

    # ファイルサイズ文字列を返す。(size は、バイト数で来ることを想定)
    def getFilesizeString(size)

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

