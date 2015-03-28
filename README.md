# slack.vim

## これは何

slackをファイル見たく編集して、ポストできるやつ  
現状はチャンネルのみ対応

![slack-vim](http://i.gyazo.com/5e3430a3d959ddc53d156611c3b2ba47.gif)

## 動作に必要なもの

- vim (perlインタフェイス)
- perl
- curl
- gunzip

## 使い方

なんか適当なパッケージマネージャで入れる

    " vim-plug
    Plug 'yaasita/slack.vim'
    " NeoBundle
    NeoBundle 'yaasita/slack.vim'
    " Vundle
    Bundle 'yaasita/slack.vim'

[SlackのAPIページ](https://api.slack.com/web)からTokenを取ってくる

vimrcとかに書いておく

    let g:yaasita_slack_token = "xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx"

ページを開く

    # generalチャンネルを開く場合
    vim slack://ch/general

チャンネルを開いて、`=== input ===`の下に書き込みたいテキストを書いて`:w`で送信できます

![ch](http://40.media.tumblr.com/cff71b8ef466be43946a3d9f78ed87e3/tumblr_nlxm3nmAqG1riy4fno1_1280.png)

チャンネル一覧を開く

    vim slack://ch/

チャンネルに合わせて`gf`で開く

![list](https://41.media.tumblr.com/003169d18d3b0818b60c75856a91d259/tumblr_nlxmda1Aig1riy4fno1_400.png)

## TODO

- リファクタリング
- Directメッセージ対応
- プライベートグループ対応
- 改行時の表示整形
- syntax
- ファイルタイプ、バッファタイプ
- tmpfile処理
