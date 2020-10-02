module BackupUtil

    require 'fileutils'

    #
    # self.get_dir_info
    #   コピー元、コピー先ディレクトリを受け取り、読みやすい形式で画面出力する。
    #   引数
    #       src     :   コピー元ディレクトリのハッシュ配列
    #       dest    :   コピー先ディレクトリのパス
    #
    def self.show_dir_info(src, dest)
        tmp = ""

        # コピー元ディレクトリを展開し、文言化する。
        src.each { |key, value|
            tmp += "　#{key}: #{value} \n"
        } 

        # 表示
        Message.show_and_log(:info, :info02, desc: tmp)
        Message.show_and_log(:info, :info03, desc: "　" + dest)
    end

    #
    # self.show_confirmation
    #   実行確認を行う。
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
                exit(true)
            else
                Message.show(:confirm04, "") 
            end
        end
    
    rescue => ex
        Message.exception(__method__, ex)
        exit(false)
    end

    # コピー実行
    def self.execute_copy(dirs)

        # バックアップディレクトリの生成
        dest_dir = File.join(dirs.dest_dir, dirs.dest_prefix+Time.new.strftime("%Y%m%d%H%M%S"))
        Dir.mkdir(dest_dir) 

        # 実行開始
        dirs.src_dir.each { |key, value| 

            # プログレスバーの生成（ソースディレクトリ名とディレクトリの容量を渡す。）
            bar = ProgressBar.new(File.basename(value), get_dir_info(value)[:dir_size])

            # ディレクトリ内のファイルコピーを実行する。
            copy_files(value, dest_dir, bar)

            # 実行完了したら、改行しておく。
            Message.show(:info04)
        }

        # 結果の表示
        tmp = get_dir_info(dest_dir)
        Message.show_and_log(:info, :info05, path: dest_dir)
        Message.show_and_log(:info, :info06, size: tmp[:dir_size], fcount: tmp[:file_count], dcount: tmp[:dir_count])

    rescue => ex
        Message.exception(__method__, ex)
        exit(false)
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

    rescue => ex
        Message.exception(__method__, ex)
        exit(false)
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
    rescue => ex
        Message.exception(__method__, ex)
        exit(false)
    end

end
