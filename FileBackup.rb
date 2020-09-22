require '.\modules\Inifile.rb'
require '.\modules\Utility.rb'
require '.\modules\Message.rb'
require '.\modules\ProgressBar.rb'

# 設定ファイルの読み込み
setting = Inifile.read(".\\setting.ini")
system = Inifile.read(".\\system.ini")

# エラー終了：設定が取れなかった場合
if !setting then
    Message.show(:err02, "", :fatal)
    exit
end

# 準備：コピー元、コピー先ディレクトリの作成
src_dir = BackupUtil.get_src_dir(setting["src"])
dest_dir = setting["destination"]["dest_dir"]
dest_prefix = setting["destination"]["dest_prefix"]

# コピー元ディレクトリがない場合、エラー終了
if src_dir.length == 0 then
    Message.show(:err03, "", :fatal)
    exit
end

# バックアップ先ディレクトリがない場合、エラー終了
# （間違っている可能性があるので、自動で作ったりしない）
if !File.directory?(dest_dir) then
    Message.show(:err04, "", :fatal)
    exit
end

# 情報表示と実行確認
BackupUtil.show_dir_info(src_dir, dest_dir)
BackupUtil.show_confirmation

BackupUtil.execute_copy(src_dir, dest_dir, dest_prefix)


# コピー先ディレクトリは、コピー実行開始直後に作る。
# Dir.mkdir destdir


