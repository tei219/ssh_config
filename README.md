# ssh_config
make ~/.ssh/config 

# ssh_config
make ~/.ssh/config

# なにこれ
多段SSHするのに ~/.ssh/config を書くのが面倒くさかったのでコマンドでかけるやつ書いたんですよ

# 使い方
## 登録
サーバ名、接続ユーザ名、IPアドレス、ポート番号 を via でつなげて書くタイプ
手前が子供、後ろが親です。親が既に登録されている場合は via のあとはサーバ名だけでOKです 

    $ ./config.sh サーバ名 接続ユーザ名 IPアドレス [ポート番号] via サーバ名 [接続ユーザ名 IPアドレス [ポート番号]] [via [...]] ...

ディレクトリをほってその下に .config ファイルを生成します

    .
    |-- config.sh
    |-- vm0617
    |   `-- .config
    |-- vm1252
    |   |-- .config
    |   |-- srv3520
    |   |   `-- .config
    |   |-- srv4876
    |   |   `-- .config
    以下略
    
## 確認
    $ ./config.sh show
現在の登録情報から ~/.ssh/config を確認できます

## 更新
    $ ./config.sh update
~/.ssh/config を更新します
    
## リスト確認
     $ ./config.sh List
登録状況を確認できます。書いたサーバが忘れたら使う

