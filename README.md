# bshoku2wp

# このツールはなに？

Blogサイト「B食倶楽部」の各ユーザの公開記事と画像をダウンロードするbashスクリプトと、ダウンロードした公開記事からWordPressにインポートできるXMLファイルを生成するRubyスクリプトです。

なお、このツールはB食倶楽部のブログデータを完全にバックアップできる、WordPressにインポートできる事を保証するものではありませんし、作者はサポートもしません。ですが、フィードバックは受け付けます。

# 開発者と著作権とフィードバック

Copyright: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>

ツールの著作権は開発者が持ちます。ですがGPLv2を採用します。
ブログのデータは各ブログ著者に著作権があります。
エキスポートしたデータも同様に、ブログ著者にあります。

# 動作環境

bashとRubyのインストールされているUNIX互換環境。Debian GNU/Linux(sid)でのみテストしてます。
その他に必要なのは以下ぐらいです。

 * nkf
 * wget
 * Ruby Nokogiri XMLライブラリ
 * Ruby uconv EUC-JP変換ライブラリ

# 使い方

ダウンロードしたディレクトリでダウンロードスクリプトを実行する。
IDはB食倶楽部のユーザID(整数)と、保存先を指定する。

    $ bash ./bshokuback.sh ID DIR

ユーザ「ryosuke(192)」で2時間弱かかるので気長に実行が終わるのを待ちます。
上記を実行し終わると指定したディレクトリができます。
そこにHTMLとimagesディレクトリに画像がダウンロードされます。

bshoku2wp.rbを実行します。引数にはダウンロードしたファイルがあるディレクトリ名を指定します。
結果は標準出力に書き出すので適当にリダイレクトしてください。

    $ ruby ./bshoku2wp.rb logs > wordpress.xml

# WordPressのインストール

移行先のWordPressをインストールします。

以下は、例としてDebian GNU/Linux環境での構築方法です。

## WordPressをインストールする

    $ sudo apt install mariadb-server
    $ sudo apt install wordpress

## MariaDBをセットアップする

パスワードは適当にやってください。

    $sudo mysql -u root
    mysql> create database wordpress;
    mysql> GRANT ALL PRIVILEGES ON wordpress.\* TO "suzume"@"localhost" IDENTIFIED BY "password";
    mysql> FLUSH PRIVILEGES;
    mysql> exit

# WordPressをインストールする。

Debian流のWordPressは利用せずに最新版をダウンロードしてインストールします。

    $ wget https://wordpress.org/latest.tar.gz
    $ tar xfvz latest.tar.gz
    $ sudo rm -rf /var/www/html
    $ sudo cp -r wordpress /var/www/html
    $ sudo chown -R www-data:www-data /var/www/html

# WordPressを設定する

WordPressをインストールしたURLにブラウザアクセスし、DBの設定やパスワードの設定を行う。
ここでは割愛する。

## 記事URLを設定する。

インポートする前に、「p=ID」になるようにする。

  * 左メニューの「設定」 -> パーマリンク設定で「基本」を選択する。

## 画像のアップロード方法を指定する。

  * 左メニューの「設定」 -> 「メディア」で「 アップロードしたファイルを年月ベースのフォルダに整理」をはずす。

# 画像をインポートする

左メニューの「メディア」から全てを投稿する。

# データをインポートする

左メニューの「ツール」から「インポート」を選択、WordPressを今すぐインストールして、インポータを実行する。

