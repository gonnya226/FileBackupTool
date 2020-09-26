module Inifile
    #
    # Inifile.read
    #   引数で指定されたIniファイルパスの内容をハッシュ配列にして返す。
    #   引数　：iniファイルパス（絶対パス、相対パスどちらも可）
    #   戻り値：２次元ハッシュ
    #           セクション無しの項目は、key => value の１次元、
    #           セクション有りの項目は、section => { key => value, ...} の２次元で格納。
    #   その他：Iniファイルの文字コードは、utf-8 固定。
    #           key が重複した場合は、後の値で上書きする。
    #           Iniファイル内で`;`のコメント使用可。`;`以降の文字列は無視する。
    #           
    def self.read(inifile_path) 

        # ローカル変数の初期化
        section = ""
        key = ""
        value = ""
        hash = Hash.new { |h,k| h[k] = {} }

        # ini ファイルを、読み取り専用でオープン
        inifile = File.open(inifile_path, "r:utf-8")

        inifile.each do |line| 

            # `;`記号がある場合はコメントと判断し、最初の`;`記号以降を除外する。
            line.sub!(/;.*/m,"") if line.match(/;/)            
            
            # 前後の空白を除去
            line.strip!

            # セクション行の場合は、セクションを設定してスキップ
            if line.match(/^\[.*\]$/) then
                # セパレータ`[]` と空白を除去して、セクション名にする。
                section = line.gsub!(/[\[\]\s]/,"")
                next
            end

            # その行が`=`を含まなければ、スキップする。
            next unless line.match(/=/) 

            # 最初の`=`で２分割して、key, value に入れる。
            # `=`の前後に空白がある場合は、それも除去する。
            key, value =  line.split(/\s*=\s*/, 2)

            # value がシングルクォート、ダブルクォートで括られている場合は、除外する。
            # value = value.sub(/^[\'\"]/,"").sub(/[\'\"]$/,"")

            # シングルクォート、ダブルクォートは全て除外。
            value = value.gsub(/[\'\"]/,"")

            # key, value の値のどちらかが空の場合は、スキップする。
            next unless key.length > 0 && value.length > 0

            # セクションがある場合は、２次元ハッシュにする。
            if section.length == 0 then
                hash[key] = value
            else
                hash[section][key] = value
            end

        end

        # ハッシュ配列を返す。
        return hash

    rescue Exception => ex
        # 例外発生時の処理:エラー情報のみ出力する。
        puts "#{__method__}: #{ex.class}: #{ex.message} "
        puts "#{ex.backtrace.join("\n")}"

    ensure
        # inifile がオープンされてたら閉じる。
        inifile.close unless inifile.closed?
    end

end
 
