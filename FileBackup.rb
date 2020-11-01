require_relative './modules/Message'
require_relative './modules/Setting'
require_relative './modules/Utility'
require_relative './modules/ProgressBar'

# 同じディレクトリにある`system.ini`の絶対パスを保持
SYSTEM_INI = File.expand_path("./system.ini", __dir__).freeze

# システム設定読み込み
sys = SystemSetting.new(SYSTEM_INI)

# メッセージクラスの初期設定
Message.init(sys) 

# ディレクトリ情報の取得
dirs = DirectorySetting.new(File.expand_path(sys.setting_path, __dir__))

# 情報表示と実行確認
BackupUtils.show_dir_info(dirs)
BackupUtils.show_confirmation

# バックアップ実行
BackupUtils.execute_copy(dirs)


