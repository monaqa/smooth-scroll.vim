"=============================================================================
" File: smooth_scroll.vim
" Author: Yuta Taniguchi
" Created: 2016-10-02
"=============================================================================

scriptencoding utf-8

if exists('g:loaded_smooth_scroll')
  finish
endif
let g:loaded_smooth_scroll = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:smooth_scroll_no_default_key_mappings') ||
\  !g:smooth_scroll_no_default_key_mappings
  nnoremap <silent> <C-d> :call smooth_scroll#flick(40, 20, 1)<CR>
  nnoremap <silent> <C-u> :call smooth_scroll#flick(40, 20, -1)<CR>
  nnoremap <silent> <C-f> :call smooth_scroll#flick(80, 20, 1)<CR>
  nnoremap <silent> <C-b> :call smooth_scroll#flick(80, 20, -1)<CR>
endif


let &cpo = s:save_cpo
unlet s:save_cpo
