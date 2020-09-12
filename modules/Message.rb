#
#   module Message
#       - i18n, logger gem を利用したメッセージ表示用モジュール
#       - message.yml に固定文を設定し、シンボルで指定して表示できる。
#         自由記述で詳細も追加表示可能。
#

module Message
    require 'i18n'
    require 'logger'

    # i18n モジュールの設定
    I18n.load_path = [".\\messages.yml"]    # 文言ファイルは固定
    I18n.locale = :ja                       # 日本語指定

    # logger の設定
    date_format = '%Y-%m-%d %H:%M:%S'           # 日時フォーマット　固定
    @applog = Logger.new('.\\FileBackup.log')   # 出力ログファイル　固定
    @applog.datetime_format = date_format

    # self.show
    #   指定されたメッセージを表示する。
    #       - コンソールに表示する。
    #   引数：固定メッセージシンボル, 詳細メッセージ（内容は呼び出し元で指定）
    #       　ログレベル（:debug, :info, :warn, :error, :fatal, :unknown）
    #               デフォルトは :none, 指定がない場合は、ログへの出力は行わない。
    #   戻り値：無し
    def self.show(label, description, level = :none)
        mes = createMessage(label, description) 

        # コンソールへ表示
        puts mes 

        # logレベルの指定がある場合は、ログへ出力する。
        case level
        when :debug, :info, :warn, :error, :fatal, :unknown 
            @applog.send(level, mes)
        end
    end

    # self.log
    #   指定されたメッセージをlogファイルに書き出す。
    #   引数：固定メッセージシンボル, 詳細メッセージ（内容は呼び出し元で指定）
    #       　ログレベル（:debug, :info, :warn, :error, :fatal, :unknown）
    #               デフォルトは :unknown, 指定に誤りがある場合も、:unknown で判断する。
    #   戻り値：無し
    def self.log(label, description, level = :unknown)
        mes = createMessage(label, description) 

        # ログレベルに従って、ログへ出力する。
        case level
        when :debug, :info, :warn, :error, :fatal 
            @applog.send(level, mes)
        else
            # 指定のログレベル以外の場合は、全て :unknown 扱いにする。
            @applog.send(:unknown, mes)
        end
    end

    private

    # self.createMessage
    #   i18n の定型文を取得し、出力する文字列を返す。
    def self.createMessage(label, description)
        return I18n.t(label, desc: description)
    end

end

