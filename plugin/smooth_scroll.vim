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
  nnoremap <silent> <C-d> :<C-u>call smooth_scroll#flick(v:count1 * winheight(0) / 2, winheight(0) / 3,  1)<CR>
  nnoremap <silent> <C-u> :<C-u>call smooth_scroll#flick(v:count1 * winheight(0) / 2, winheight(0) / 3, -1)<CR>
  nnoremap <silent> <C-f> :<C-u>call smooth_scroll#flick(v:count1 * winheight(0)    , winheight(0) / 2,  1)<CR>
  nnoremap <silent> <C-b> :<C-u>call smooth_scroll#flick(v:count1 * winheight(0)    , winheight(0) / 2, -1)<CR>
endif


let &cpo = s:save_cpo
unlet s:save_cpo
