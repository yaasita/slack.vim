" vim: set sw=4 et fdm=marker:
"
"
" r2puki2.vim - Convert RedmineWiki to Pukiwiki
"
" Version: 0.2
" Maintainer:	yaasita < https://github.com/yaasita/r2puki2 >
" Last Change:	2014/05/09.

function! r2puki2#convertpukiwiki() "{{{
    if (&ft == "redmine")
        " heading
        silent! %s/^h1\. \(.\+\)\n\+/* \1\r/
        silent! %s/^h2\. \(.\+\)\n\+/** \1\r/
        silent! %s/^h3\. \(.\+\)\n\+/*** \1\r/
        " index
        silent! %s/{{toc}}/#contents/
        " link
        silent! %s/^!\([^!]\+\)!/\&ref(\1);/
        " pre
        let lnum = 1
        let inpre = 0
        while lnum <= line("$")
            let cline = getline(lnum)
            if ( match(cline,"<pre>") > -1 )
                let inpre = 1
            elseif ( match(cline,"</pre>") > -1 )
                let inpre = 0
            endif

            if ( inpre == 1 )
                exec lnum . "s/^/ /"
            endif
            let lnum += 1
        endwhile
        silent! g/<\/\?pre>/d
    endif
endfunction "}}}
function! r2puki2#convertredmine() "{{{
    if (&ft == "markdown" || &ft == "mkd")
        " heading
        silent! %s/\v^# (.+)/h1. \1\r/
        silent! %s/\v^## (.+)/h2. \1\r/
        silent! %s/\v^### (.+)/h3. \1\r/
        " list
        silent! %s/\v^(\-|\+) /* /
        silent! %s/\v^    (\-|\+) /** /
        silent! %s/\v^        (\-|\+) /*** /
        " pre
        silent! %s/\v^\n\s{4}(.+)/\r<pre>\r    \1/
        silent! %s/\v^\s{4}(.+)\n\n/    \1\r<\/pre>\r\r/
        " image
        silent! %s/\v^!\[(.+)\]\((.+)\)/\r!\2!\r/
        " link
        silent! %s/\v^\[(.+)\]\((.+)\)/"\1":\2\r/
        " quote
        silent! %s/\v`(.{-})`/ *\1* /g
        set ft=redmine
    endif
endfunction "}}}
