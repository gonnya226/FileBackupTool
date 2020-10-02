require './modules/Message.rb'
require './modules/Setting.rb'
require './modules/Utility.rb'
require './modules/ProgressBar.rb'

SYSTEM_INI = "./system.ini".freeze

# システム設定読み込み
sys = SystemSetting.new(SYSTEM_INI)

# メッセージクラスの初期設定
Message.init(sys) 

# ディレクトリ情報の取得
dirs = DirectorySetting.new(sys.setting_path)

# 情報表示と実行確認
BackupUtil.show_dir_info(dirs)
BackupUtil.show_confirmation

BackupUtil.execute_copy(dirs)


