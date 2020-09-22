module BackupUtil

    require 'fileutils'

    #
    # self.get_src_dir
    #   コピー元ディレクトリのハッシュを受け取り、有効なパスのみのハッシュにして戻す。
    #   引数
    #       src :   ディレクトリのハッシュ配列
    #   戻り値
    #       有効なパスを持つディレクトリのハッシュ配列
    #
    def self.get_src_dir(src)
        tmp = Hash.new
        src.each do |key, value| 
            # 指定したディレクトリが在る場合のみ、ハッシュに追加する。
            if File.directory?(value) then
                tmp[key] = value
            else
                Message.show(:warn01, "#{key}: #{value} ", :warn )
            end
        end

        return tmp

    rescue Exception => ex
        Message.show(:err11, "#{__method__}: #{ex.class}: #{ex.message}", :fatal)
    end

    #
    # self.get_dir_info
    #   コピー元、コピー先ディレクトリを受け取り、読みやすい形式で画面出力する。
    #   引数
    #       src     :   コピー元ディレクトリのハッシュ配列
    #       dest    :   コピー先ディレクトリのパス
    #   戻り値
    #       なし
    #
    def self.show_dir_info(src, dest)
        tmp = ""

        # コピー元ディレクトリを展開し、文言化する。
        src.each { |key, value|
            tmp += "　#{key}: #{value} \n"
        } 

        # 表示
        Message.show(:info01, tmp, :info)
        Message.show(:info02, "　" + dest, :info)

    rescue Exception => ex
        Message.show(:err12, "#{__method__}: #{ex.class}: #{ex.message}", :fatal )
    end

    #
    # self.show_confirmation
    #   実行確認のための処理を行う。
    #   引数
    #       なし
    #   戻り値
    #       なし
    #
    def self.show_confirmation

        # 処理の実行確認メッセージ
        loop do 
            Message.show(:confirm01, "")
            answer = gets

            case answer.strip.upcase
            when "Y", ""
                Message.show(:confirm02, "")
                break
            when "N"
                Message.show(:confirm03, "")
                exit
            else
                Message.show(:confirm04, "") 
            end
        end
    rescue Exception => ex
        Message.show(:err13, "#{__method__}: #{ex.class}: #{ex.message}", :fatal )
    end

    # コピー実行
    def self.execute_copy(src, dest, prefix)

        # バックアップディレクトリの生成
        dest_dir = File.join(dest, prefix+Time.new.strftime("%Y%m%d%H%M%S"))
        Dir.mkdir(dest_dir) 

        # 実行開始
        src.each { |key, value| 

            # プログレスバーの生成（ソースディレクトリ名とディレクトリの容量を渡す。）
            bar = ProgressBar.new(File.basename(value), get_dir_info(value)[:dir_size])

            # ディレクトリ内のファイルコピーを実行する。
            copy_files(value, dest_dir, bar)

            # 実行完了したら、改行しておく。
            Message.show(:info03, "", :info)
        }

        # 結果の表示
        tmp = get_dir_info(dest_dir)
        Message.show(:info04, "バックアップ先：#{dest_dir}", :info)
        Message.show(:free, "  Total: #{tmp[:dir_size]}, ファイル数: #{tmp[:file_count]}, ディレクトリ数: #{tmp[:dir_count]} ", :info)

    rescue Exception => ex
         # 例外発生時の処理
         Message.show(:err11, " #{ex.class}: #{ex.message}", :fatal)
    ensure

    end

    private

    # 指定したディレクトリの容量、ファイル数、フォルダー数を計算する。
    def self.get_dir_info(directory)
        dir_size = 0      # 総サイズ計算用
        file_count = 0    # 総ファイル数計算用
        dir_count = 0     # 総ディレクトリ数計算用
    
        # オブジェクト一覧を取得
        # `.`付きのフォルダーも取得するが、`.`で終わる特殊フォルダーは除外する。
        list = Dir.glob(File.join(directory, "**", "*"), File::FNM_DOTMATCH).reject{|x| x =~ /\.$/}

        list.each { |f| 
            # ディレクトリではない場合のみ、サイズを加算する。
            if File::ftype(f) != "directory" then
                dir_size += File.size(f)    # ファイルサイズのカウント
                file_count += 1             # ファイル数のカウント
            else
                dir_count += 1              # ディレクトリ数のカウント
            end
        }

        # 総サイズを返す。
        return Hash[dir_size: dir_size, file_count: file_count, dir_count: dir_count]
    end

    # ディレクトリ内のファイルをコピーする。
    def self.copy_files(src, dest, bar)

        # コピー元のディレクトリ名を取得し、コピー先にその名前のディレクトリを生成する。
        dest_dir = File.join(dest, File.basename(src))
        Dir.mkdir(dest_dir)

        # コピー元のディレクトリ内のディレクトリ／ファイルの一覧取得(`.`, `..`は取得しない)
        list = Dir.glob(File.join(src, "*"))

        list.each { |f| 
            if File::ftype(f) == "directory"
                # ディレクトリの場合、そのディレクトリをソースディレクトリとして、再帰呼び出しする。
                copy_files(f, dest_dir, bar)
            else
                # ファイルの場合、プログレスバーを更新して、ファイルコピー実行
                bar.show(File.basename(f), File.size(f))
                FileUtils.copy(f, dest_dir)
            end
        }

    rescue Exception => ex        # 例外発生時の処理
        Message.show(:err11, " #{ex.class}: #{ex.message}", :fatal)
    ensure

    end

end
