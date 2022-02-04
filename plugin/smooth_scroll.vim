"=============================================================================
" File: smooth_scroll.vim
" Author: Mogami Shinichi
" Created: 2019-06-02
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
  nnoremap <C-d> <Cmd>call smooth_scroll#flick( v:count1 * &scroll     , winheight(0) / 3)<CR>
  nnoremap <C-u> <Cmd>call smooth_scroll#flick(-v:count1 * &scroll     , winheight(0) / 3)<CR>
  nnoremap <C-f> <Cmd>call smooth_scroll#flick( v:count1 * winheight(0), winheight(0) / 2)<CR>
  nnoremap <C-b> <Cmd>call smooth_scroll#flick(-v:count1 * winheight(0), winheight(0) / 2)<CR>
  vnoremap <C-d> <Cmd>call smooth_scroll#flick( v:count1 * &scroll     , winheight(0) / 3)<CR>
  vnoremap <C-u> <Cmd>call smooth_scroll#flick(-v:count1 * &scroll     , winheight(0) / 3)<CR>
  vnoremap <C-f> <Cmd>call smooth_scroll#flick( v:count1 * winheight(0), winheight(0) / 2)<CR>
  vnoremap <C-b> <Cmd>call smooth_scroll#flick(-v:count1 * winheight(0), winheight(0) / 2)<CR>
endif


let &cpo = s:save_cpo
unlet s:save_cpo
