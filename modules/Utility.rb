module BackupUtils

    require 'fileutils'
    #
    # self.get_dir_info
    #   ディレクトリ情報を受け取り、読みやすい形式で画面出力する。
    #   引数
    #       dirs    : バックアップディレクトリ情報
    #
    def self.show_dir_info(dirs)
        tmp = ""

        # バックアップ元ディレクトリを展開し、文言化する。
        dirs.src_dir.each { |key, value|
            tmp += Message.t(:info09, key: key, value: value)
        } 

        # 表示
        Message.show_and_log(:info, :info02, desc: tmp)
        Message.show_and_log(:info, :info03, desc: dirs.dest_dir)
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

    #
    # self.execute_copy
    #   バックアップ先へ、ディレクトリ作成、ファイルコピーを行う。
    #   引数
    #       dirs    ：  バックアップ元、バックアップ先ディレクトリ情報
    #
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

    #
    # self.get_dir_info
    #   引数のディレクトリの情報を取得する。
    #   引数
    #       directory   :   情報を取得するディレクトリパス
    #   戻り値
    #       ハッシュ配列（ディレクトリの総サイズ、ファイル数、ディレクトリ数）
    #
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

    #
    # self.copy_files
    #   ディレクトリの作成、ファイルのコピーを行う。
    #   再帰呼び出しを行うことで、配下のファイル、ディレクトリ全てを作成、コピーする。
    #   引数
    #       src     :   コピー元のディレクトリ（単体。ハッシュではないので注意）
    #       dest    :   コピー先のディレクトリ
    #       bar     :   プログレスバーオブジェクト
    #
    def self.copy_files(src, dest, bar)

        # バックアップ元のディレクトリ名を取得し、バックアップ先にその名前のディレクトリを生成する。
        dest_dir = File.join(dest, File.basename(src))

        # バックアップ先に同じ名前のディレクトリがすでにある場合は、"_"を付与。
        # ディレクトリの重複が無くなるまで、"_"を付与し続ける。
        while Dir.exists?(dest_dir)
            dest_dir = dest_dir + "_"
        end

        Dir.mkdir(dest_dir)
        Message.log(:info, :info07, dir: dest_dir.to_s)

        # バックアップ元のディレクトリ内のディレクトリ／ファイルの一覧取得(`.`, `..`は取得しない)
        list = Dir.glob(File.join(src, "*"), File::FNM_DOTMATCH).reject{|x| x =~ /\.$/}

        list.each { |f| 
            if File::ftype(f) == "directory"
                # ディレクトリの場合、そのディレクトリをソースディレクトリとして、再帰呼び出しする。
                copy_files(f, dest_dir, bar)
            else
                # ファイルの場合、プログレスバーを更新して、ファイルコピー実行
                bar.show(File.basename(f), File.size(f))
                FileUtils.copy(f, dest_dir)
                Message.log(:info, :info08, file: f.to_s)
            end
        }
    rescue => ex
        Message.exception(__method__, ex)
        exit(false)
    end

    #
    # self.add_thouzands_separator
    #   文字列に３桁セパレータを付与する。（セパレータ文字はカンマ）
    #   引数
    #       str     :   対象オブジェクト（to_s関数を持っていれば、何でもいい）
    #   戻り値
    #       str.to_s に３桁区切りを付与した文字列
    #
    def self.add_thousands_separator(str)
        return str.to_s.reverse.scan(/.{1,3}/).join(",").reverse
    end

end
