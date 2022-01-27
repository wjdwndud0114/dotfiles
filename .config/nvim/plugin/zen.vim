" Custom function for zen mode :)
let g:zen_mode = 0
function! ToggleZenMode()
  let g:zen_mode = !g:zen_mode
  if g:zen_mode
    silent wincmd |
  else
    silent wincmd =
  endif
endfunction
map <silent> <Leader>z :call ToggleZenMode()<CR>

function! ZenMode()
  if g:zen_mode
    wincmd |
  endif
endfunction
au WinEnter * call ZenMode()
set winminwidth=10

