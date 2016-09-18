augroup Slack
  autocmd!
  autocmd BufReadCmd slack://* call slack#OpenCh(expand("<amatch>"))
  autocmd BufWriteCmd slack://* call slack#WriteCh(expand("<amatch>"))
augroup END
