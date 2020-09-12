module BackupUtil

    # バックアップ元ディレクトリの取得
    def self.getSrcDir(src)
        directories = Hash.new
        src.each do |key, value| 
            if File.directory?(value) then
                directories[key] = value
            else
                puts "#{key} の設定先 #{value} はディレクトリではありません。"
            end
        end

        return directories
    end

    def self.showFolderInfomation

    end

    # 確認メッセージ表示
    def self.showConfirmation
        loop do 
            print "処理を開始してよろしいですか？[Y/n] "
            answer = gets

            case answer.strip.upcase
            when "Y", ""
                puts "処理を開始します。"
                break
            when "N"
                puts "処理を中止します。"
                exit
            else
                puts "【エラー】`y`か`n`で入力してください。"
            end
        end
    end

end
