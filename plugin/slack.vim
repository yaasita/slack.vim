augroup Slack
  autocmd!
  autocmd BufReadCmd slack://* call slack#Openslack()
augroup END
