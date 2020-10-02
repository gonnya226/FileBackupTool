require './modules/Message.rb'
require './modules/Setting.rb'
require './modules/Utility.rb'
require './modules/ProgressBar.rb'

SYSTEM_INI = "./system.ini".freeze

# システム設定読み込み
sys = SystemSetting.new(SYSTEM_INI)

# メッセージクラスの初期設定
if !Message.init(sys) then
    puts SYSTEMERROR02
    exit(false)
end

dirs = DirectorySetting.new(sys.setting_path)

# 情報表示と実行確認
BackupUtil.show_dir_info(dirs.src_dir, dirs.dest_dir)
BackupUtil.show_confirmation

BackupUtil.execute_copy(dirs)


