augroup Slack
  autocmd!
  autocmd BufReadCmd slack://ch/* call slack#OpenCh(expand("<amatch>"))
  autocmd BufWriteCmd slack://ch/* call slack#WriteCh(expand("<amatch>"))
augroup END
