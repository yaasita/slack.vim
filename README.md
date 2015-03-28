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

チャンネル一覧を開く

## TODO

- Directメッセージ対応
- プライベートグループ対応
- 改行時の表示整形
