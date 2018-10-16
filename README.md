# なにこれ
多段SSHするのに ~/.ssh/config を書くのが面倒くさかったのでコマンドでかけるやつ書いたんですよ  

# 使い方
## 登録
サーバ名、接続ユーザ名、IPアドレス、ポート番号 を via でつなげて書くタイプ  
手前が子供、後ろが親です。親が既に登録されている場合は via のあとはサーバ名だけでOKです  

    $ ./config.sh サーバ名 接続ユーザ名 IPアドレス [ポート番号] [via サーバ名 [接続ユーザ名 IPアドレス [ポート番号]] [via [...]] ... ]

ディレクトリをほってその下に .config ファイルを生成します  

    .
    |-- config.sh
    |-- vmxxxx
    |   `-- .config
    |-- vmyyyy
    |   |-- .config
    |   |-- srvzzzz
    |   |   `-- .config
    |   |-- srvpppp
    |   |   `-- .config
    以下略
    
## 確認
    $ ./config.sh show
現在の登録情報から ~/.ssh/config を確認できるよ  

## 更新
    $ ./config.sh update
~/.ssh/config を更新します  
    
## リスト確認
    $ ./config.sh list
登録状況を確認できます。書いたサーバが忘れたら使う  

## オートログイン用
   $ ./config exp vmxxxx
vmxxxx のオートログインように except スクリプトを作成します  
