require '.\modules\Inifile.rb'
require '.\modules\Utility.rb'
require '.\modules\Message.rb'



# 設定ファイルの読み込み
setting = Inifile.read(".\\settinfg.ini")

# エラー終了：設定が取れなかった場合
if !setting then
    # logger.fatal("設定ファイルの読み込みでエラーが発生しました。")
    exit
end

p "終了"
exit

# 準備：コピー元ディレクトリの配列生成''
srcdir = BackupUtil.getSrcDir(setting["src"])

# 準備：コピー先ディレクトリの作成
dest_dir = setting["destination"]["dest_dir"]
dest_prefix = setting["destination"]["dest_prefix"]

# 準備：ログ出力先
log_dir = setting["log"]["log_dir"]
log_prefix = setting["log"]["log_prefix"]

# エラー終了：バックアップ先フォルダーがない場合
if !File.directory?(dest_dir) then
    # ShowResult.showError(ShowResult::ERR02)
    # destdir = File.join(dest["dest_dir"], dest["dest_prefix"] + Time.new.strftime("%Y%m%d%H%M%S"))
end

BackupUtil.showConfirmation

puts "File Backup!"


# コピー先ディレクトリは、コピー実行開始直後に作る。
# Dir.mkdir destdir


