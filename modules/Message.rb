#
#   module Message
#
module Message
    require 'I18n'
    require 'logger'

    # i18n 初期設定
    begin
        I18n.load_path = Dir["./locale/**/*.yml"]
        I18n.locale = :ja
    rescue I18n::InvalidLocaleData
        # ロケールファイルのオープンエラー
        puts "ロケールファイルの読み込みに失敗しました。\n処理を中止します。"
        exit(false)
    rescue I18n::InvalidLocale
        # 不正なロケールを指定した
        puts "ロケールの設定「:ja」が見つかりません。\n処理を中止します。"
        exit(false)
    end

    #
    # self.init
    # システム設定を受け取り、Messageクラスの設定を行う。
    #   引数
    #       system  :   設定のハッシュ。下記項目が入っていることを想定。
    #                   log_path        :   ログファイル出力パス
    #                   log_date_format :   ログ出力時の日付フォーマット
    #   戻り値
    #       なし
    #
    def self.init(sys)
        # system.ini の内容で初期化する。
        @log_path = sys.log_path
        @log_date_format = sys.log_date_format

        # logへ最初の書き込みを行ってみる。
        self.show_and_log(:info, :info01, desc: Time.new.strftime("%Y-%m-%d %H:%M"))

        return true
    end

    #
    # self.show
    #   コンソールへ表示する。
    #   引数
    #       label   :   ロケールファイルのラベル（シンボル）
    #       *args   :   パラメータ（I18n仕様）
    #
    def self.show(label, *args)
        puts t(label, *args)
    end

    #
    # self.log
    #   ログへ出力する。
    #   引数
    #       level   :   ログレベル（通常外の値を指定した場合は :unknown で出力）
    #       label   :   ロケールファイルのラベル（シンボル）
    #       *args   :   パラメータ（I18n仕様）
    #
    def self.log(level, label, *args)
        # ログファイルへ書き込み
        write_log(level, t(label, *args))
    end

    #
    # self.show_and_log
    #   コンソールとログへ出力する。（show と log を順に呼び出すだけ）
    #   引数
    #       level   :   ログレベル（通常外の値を指定した場合は :unknown で出力）
    #       label   :   ロケールファイルのラベル（シンボル）
    #       *args   :   パラメータ（I18n仕様）
    #
    def self.show_and_log(level, label, *args)
        show(label, *args)
        log(level, label, *args)
    end

    #
    # self.exception
    #   例外情報を出力する。
    #       コンソールとログの両方に出力する。
    #       メソッド名、Exceptionクラス、Exceptionメッセージ、backtrace を出力する。
    #   引数
    #       method      :   発生したメソッド名（__method__ で渡してもらう）
    #       ex          :   Exception オブジェクト
    #
    def self.exception(method, ex)        
        # コンソールとログへ出力（レベルは :fatal, 文言は:exception固定）
        show_and_log(:fatal, :exception, method: method, class: ex.class, message: ex.message, backtrace: ex.backtrace.join("\n"))
    end

    private

    #
    # self.write_log
    # ログファイルへの書き込み
    #   引数
    #       level   :   ログレベル（:debug, :info, :warn, :error, :fatal, :unknown）
    #       message :   出力する内容
    #
    #   ※ 出力直前にオープンし、出力後に必ずcloseするようにする。
    #
    def self.write_log(level, message)
        # loggerオブジェクト生成
        @logger = Logger.new(@log_path)
        @logger.datetime_format = @log_date_format

        # 指定のログレベル以外の値が来た場合は、:unknown に置き換える。
        unless [:debug, :info, :warn, :error, :fatal].include?(level) then
            level = :unknown
        end

        # 出力実行
        @logger.send(level, message)
        @logger.close

    rescue => ex
        # ここで例外が発生した場合、ログに出力できない状態なので、コンソールに直接出力する。
        puts t(:err06, path: sys.log_path)
        puts t(:exception, method: __method__, class: ex.class, message: ex.message, backtrace: ex.backtrace.join("\n"))
        exit(false)
    end

    #
    # self.t
    # メッセージ文を取得する。I18n.t へそのまま引き継ぐ。
    #   引数
    #       label   :   メッセージ文を指定するシンボル
    #       *args   :   引数リスト
    #
    def self.t(label, *args)
        return I18n.t(label, *args)
    end
    
end

