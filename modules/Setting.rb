require './modules/Inifile'
require 'securerandom'

#
#   class SettingBase
#       - iniファイルの内容を読み取り、変数に格納する。
#       - このクラスは読み取り機能のみ実装。
#         内容の取得は、このクラスを継承して実装すること
#
class SettingBase
    include Inifile

    def initialize(path)
        # path ファイルの内容を読み込む。
        @ini = read(path)
    end

    private

    #
    # yen_to_slash
    #   円記号をスラッシュに置換する。
    #   引数
    #       str :   文字列
    #   戻り値
    #       文字列内の円記号をスラッシュに置き換えた文字列
    #
    def yen_to_slash(str)
        return str.gsub("\\", "/")
    end
end

class SystemSetting < SettingBase
    # 配列でインスタンス変数のgetterをまとめて定義
    VARS = [:log_path, :log_date_format, :setting_path].freeze
    attr_reader *VARS

    def initialize(path)
        # path の内容を読み込む。変数 @ini に格納される。
        super(path)

        # SystemSetting で必要な変数のみ取得を試みる。
        VARS.each do |param| 
            tmp = param.to_s
            
            if @ini.keys.include? tmp then
                # 該当するキーがあれば、インスタンス変数に読み込み。
                # ※ 全てのパラメータで、yen_to_slashの置換もしてしまう。
                # self.send(tmp+"=", yen_to_slash(@ini[tmp]))
                eval("@#{tmp} = yen_to_slash(@ini[tmp])")
            else
                # 該当するキーがない場合は、エラーを表示する。
                Message.show(:err03, param: tmp, path: path)
                exit(false)
            end
        end
    end
end

class DirectorySetting < SettingBase
    # 配列でインスタンス変数のgetterをまとめて定義
    VARS = [:src_dir, :dest_dir, :dest_prefix].freeze
    attr_reader *VARS
   
    def initialize(path)
        
        super(path)

        # DirectorySetting で必要な変数のみ取得を試みる。
        VARS.each do |var| 
            if var == :src_dir then
                # src_dir は複数取るので別枠で処理する。
                @src_dir = get_src_dir(@ini["src"])
            else
                # destination セクションの値
                tmp = var.to_s
                dest = @ini["destination"]

                if dest.keys.include? tmp then
                    # 該当するキーがあれば、インスタンス変数に読み込み。
                    # ※ 全てのパラメータに円マーク不要なので、パスかどうかにかかわらず置換もしてしまう。
                    # self.send(tmp+"=", yen_to_slash(dest[tmp]))
                    eval("@#{tmp} = yen_to_slash(dest[tmp])")
                else
                    # 該当するキーがない場合は、エラーを表示する。
                    Message.show_and_log(:error, :err03, param: tmp, path: path)
                    exit(false)
                end    
            end
        end

        # パラメータのチェック
        if !File.directory?(@dest_dir) then
            Message.show_and_log(:error, :err04, path: @dest_dir)
            exit(false)
        end

        if @dest_prefix.match(/[^a-zA-Z0-9_\-=()]/) then
            Message.show_and_log(:error, :err05)
            exit(false)    
        end

        # バックアップ先ディレクトリの書き込み権限チェック
        begin
            # 名前がランダムなフォルダーを作って消してみる。
            testdir = File.join(@dest_dir, SecureRandom.alphanumeric(10))
            Dir.mkdir(testdir)
            Dir.rmdir(testdir)
        rescue Errno::EACCES
            Message.show_and_log(:error, :err08, path: @dest_dir)
            exit(false)
        rescue => ex
            Message.exception(__method__, ex)
            exit(false)
        end

    end

    private

    #
    # get_src_dir
    #   バックアップ元ディレクトリのハッシュを受け取り、有効なパスのみのハッシュにして戻す。
    #   引数
    #       src :   ディレクトリのハッシュ配列
    #   戻り値
    #       有効なパスを持つディレクトリのハッシュ配列
    #
    def get_src_dir(src)
        tmp = Hash.new

        src.each do |key, value| 
            # 指定したディレクトリが在る場合のみ、ハッシュに追加する。
            if File.directory?(value) then
                # Windowsのパス区切り`\`は、`/`に直しておく。
                tmp[key] = yen_to_slash(value)
            else
                Message.show_and_log(:warn, :warn01, desc: "#{key}: #{value} ")
            end
        end

        # バックアップ元ディレクトリが一つもない場合
        if tmp.length == 0 then
            Message.show_and_log(:error, :err07, :fatal)
            exit(false)
        end
    
        return tmp

    rescue => ex
        Message.exception(__method__, ex)
        exit(false)
    end

end

