# bshoku2wp

# このツールはなに？

Blogサイト「B食倶楽部」の各ユーザの公開記事と画像をダウンロードするRubyスクリプトと、ダウンロードした公開記事からWordPressにインポートできるXMLファイルを生成するRubyスクリプトです。

なお、このツールはB食倶楽部のブログデータを完全にバックアップできる、WordPressにインポートできる事を保証するものではありませんし、作者はサポートもしません。ですが、フィードバックは受け付けます。

# 開発者と著作権とフィードバック

Copyright: Ryosuke KUTSUNA <ryosuke@deer-n-horse.jp>

ツールの著作権は開発者が持ちます。ですがGPLv2を採用します。
ブログのデータは各ブログ著者に著作権があります。
エキスポートしたデータも同様に、ブログ著者にあります。

# 動作環境

RubyのインストールされているUNIX互換環境。Debian GNU/Linux(sid)でのみテストしてます。
その他に必要なのは以下ぐらいです。

 * Ruby Nokogiri XMLライブラリ
 * Ruby uconv EUC-JP変換ライブラリ

# 使い方

ダウンロードしたディレクトリでダウンロードスクリプトを実行する。
IDはB食倶楽部のユーザID(整数)と、保存先を指定する。

    $ ruby bshokuback.rb ID DIR

ユーザ「ryosuke(192)」で2時間弱かかるので気長に実行が終わるのを待ちます。
上記を実行し終わると指定したディレクトリができます。
そこにHTMLとimagesディレクトリに画像がダウンロードされます。

bshoku2wp.rbを実行します。

-dオプションにはダウンロードしたファイルがあるディレクトリ名を指定します。
-oオプションには「all」、「text」、「image」、「category」を引数に指定でき、それぞれ全部、記事だけ、画像だけ、カテゴリーの出力選択ができます。
結果は標準出力に書き出すので適当にリダイレクトしてください。

とりあえず三種類出力しておくといいでしょう。imageで出力したXMLは、WordPressではいらないかもです。

    $ ruby bshoku2wp.rb -d bshoku-backup -o category > category.xml
    $ ruby bshoku2wp.rb -d bshoku-backup -o text > text.xml
    $ ruby bshoku2wp.rb -d bshoku-backup -o image > image.xml

画像ファイルが「image/年/月」のディレクトリ構成に配置されていない場合、tools/imgrelocate.rb を使って場所変更をしてください。このツールは記事ファイルを読み込み、リンクされている画像を、記事の時刻に併せて配置変え、タイムスタンプを更新します。

    $ ruby tools/imgrelocate.rb bshoku-backup/images bshoku-backup/article-1234.html

# WordPressのインストール

移行先のWordPressをインストールします。

以下は、例としてDebian GNU/Linux環境での構築方法です。

## WordPressをインストールする

    $ sudo apt install mariadb-server
    $ sudo apt install wordpress

## MariaDBをセットアップする

DBユーザ名、パスワードは適当にやってください。

    $sudo mysql -u root
    mysql> create database wordpress;
    mysql> GRANT ALL PRIVILEGES ON wordpress.* TO "admin"@"localhost" IDENTIFIED BY "password";
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

## PHPの設定変更

アップロードするファイルサイズによっては設定変更が必要です。
以下のファイルのパラメータを変更してapache2を再起動しておきましょう。

  * /etc/php/7.0/apache2/php.ini

      post_max_size = 40M
      upload_max_filesize = 30M

## 記事URLを設定する。

インポートする前に、「p=ID」になるようにする。

  * 左メニューの「設定」 -> パーマリンク設定で「基本」を選択する。

# 画像をインポートする

画像はあらかじめWordPressが稼働してるサーバのDocumentRoot以下 DOCUMENTROOT/wp-content/uploads以下にアップロードしておきます。

一度、WordPressにデータを入れて、他のブログに移行するためにエキスポートするならば、以下のメディア登録は不要です。

今後もWordPressでブログを書くなら、ブログ記事の中に画像を入れるためにメディアライブラリに画像を登録する必要があります。配置した大量の画像をメディアライブラリに登録するには、WordPressの「Media from FTP」プラグインを使います。

「プラグイン」から「新規作成」を選択して「Media from FTP」プラグインをインストール・有効化してください。

Media From FTPの「設定」リンクをクリックします。
日付は「ファイルの日時を取得し、それに基づいて更新。必要に応じて変更。Exif情報の日時がある場合に優先的に取得する。 」にチェックを変更します。

「検索&登録」ボタンを押し、リストされた画像全てを登録します。
検索は非常に時間がかかりますし、登録も非常に時間がかかります。根気よくがんばりましょう。

# データをインポートする

左メニューの「ツール」から「インポート」を選択、WordPressを今すぐインストールして、インポータを実行する。

メディアのインポートに失敗したメッセージが出ます。
でも上の「画像をインポートする」で画像を上げておけば見られるはずです。

# 他のブログに移行するためにデータをエキスポートする

左メニューの「ツール」から「エキスポート」を選択します。

移行先ブログに寄っては、インポートできるデータ容量の上限が決まってることがあります。(例えばライブドアブログでは8MBです。)制限容量に併せて出力期間を設定して出力しましょう。

画像は、移行先ブログによっては、インポート時に元ブログから画像をダウンロードしてくれます。この場合は元のWordPressに画像が配置されており、移行先ブログからアクセスできる必要があります。

移行先ブログで画像を設置できる場合もあります。そのまま配置して、その画像ファイル名でアクセスできることもありますが、仕様によってはファイル名が変更されることもあります。その場合は各自で対応する必要があります。少なくとも、ライブドアブログでは、画像をアップロードしてブログ記事に画像を配置すると、アップロードした画像とは異なるファイル名がブログ記事に書かれました。
