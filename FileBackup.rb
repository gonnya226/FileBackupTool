require './modules/Message'
require './modules/Setting'
require './modules/Utility'
require './modules/ProgressBar'

SYSTEM_INI = "./system.ini".freeze

# システム設定読み込み
sys = SystemSetting.new(SYSTEM_INI)

# メッセージクラスの初期設定
Message.init(sys) 

# ディレクトリ情報の取得
dirs = DirectorySetting.new(sys.setting_path)

# 情報表示と実行確認
BackupUtils.show_dir_info(dirs)
BackupUtils.show_confirmation

# バックアップ実行
BackupUtils.execute_copy(dirs)


