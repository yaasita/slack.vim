" vim: set sw=4 et fdm=marker:
"
"
" r2puki2.vim - Convert RedmineWiki to Pukiwiki
"
" Version: 0.2
" Maintainer:	yaasita < https://github.com/yaasita/r2puki2 >
" Last Change:	2015/03/25.

function! slack#OpenCh(slack_url) "{{{
    let tmpfile = tempname()
    let server_name = matchstr(a:slack_url,'\v/[a-zA-Z0-9\-]+$')
    call s:Channel2ID(server_name)
    "call system('curl -s "https://slack.com/api/channels.list?token=' . g:yaasita_slack_token . '&pretty=1" > ' . tmpfile)
    exe "e ".tmpfile
endfunction "}}}
function! s:Channel2ID(ch_name) "{{{
	perl << EOF
		VIM::Msg("pearls are nice for necklaces");
		VIM::Msg("rubys for rings");
		VIM::Msg("pythons for bags");
		VIM::Msg("tcls????");
EOF
endfunction "}}}
