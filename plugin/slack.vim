augroup Slack
  autocmd!
  autocmd BufReadCmd slack://ch/* call slack#OpenCh(expand("<amatch>"))
augroup END
