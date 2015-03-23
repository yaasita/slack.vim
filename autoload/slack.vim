" vim: set sw=4 et fdm=marker:
"
"
" r2puki2.vim - Convert RedmineWiki to Pukiwiki
"
" Version: 0.2
" Maintainer:	yaasita < https://github.com/yaasita/r2puki2 >
" Last Change:	2015/03/24.

function! slack#Openslack() "{{{
    let tmpfile = tempname()
    call system('curl -s "https://slack.com/api/channels.list?token=' . g:yaasita_slack_token . '&pretty=1" > ' . tmpfile)
    exe "e ".tmpfile
endfunction "}}}
