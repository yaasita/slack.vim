# slack.vim

## これは何

slackをファイル見たく編集して、ポストできるやつ  
現状はチャンネルのみ対応

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

    vim slack://ch/general

チャンネルを開いて、`=== input ===`の下に書き込みたいテキストを書いて`:w`で送信できます

![ch](http://40.media.tumblr.com/cff71b8ef466be43946a3d9f78ed87e3/tumblr_nlxm3nmAqG1riy4fno1_1280.png)

チャンネル一覧を開く

    vim slack://ch/

## TODO

- リファクタリング
- Directメッセージ対応
- プライベートグループ対応
- 改行時の表示整形
- syntax
- ファイルタイプ、バッファタイプ
