"=============================================================================
" File: smooth_scroll.vim
" Author: Mogami Shinichi
" Created: 2019-06-02
"=============================================================================

scriptencoding utf-8

if !exists('g:loaded_smooth_scroll')
    finish
endif
let g:loaded_smooth_scroll = 1

let s:save_cpo = &cpo
set cpo&vim

" Default parameter values
if !exists('g:smooth_scroll_add_jumplist')
  let g:smooth_scroll_add_jumplist = v:false
endif
if !exists('g:smooth_scroll_interval')
  let g:smooth_scroll_interval = 1000.0 / 60
endif
if !exists('g:smooth_scroll_scrollkind')
  let g:smooth_scroll_scrollkind = "quadratic"
endif

if g:smooth_scroll_add_jumplist
  augroup smooth_scroll
    autocmd!
    autocmd CursorMoved * if !s:smooth_scroll_is_active | let s:smooth_scroll_is_continuous = v:false | endif
  augroup END
endif

" smooth scroll がアクティブかどうか。
let s:smooth_scroll_is_active = v:false

" 直前のカーソル移動コマンドも smooth scroll によるものだったか。
let s:smooth_scroll_is_continuous = v:false

" 時間カウント．1動作のたびにカウントアップする．
" 画面遷移系のコマンドが押されると0にリセットされる．
let s:time = 0

" スクロールする目標となる行数．
" 正の値なら下向きに，負の値なら上向きに移動しようとしている．
" コマンドが押されると，残っていた（移動しきっていない）残数が加算される．
let s:goal = 0

" 現状の位置． s:goal にどこまで近づいているか．
let s:nowpos = 0

" スクロールにかける時間．数字は初期化のためで現在特に意味はない．
let s:n_time = 20

" スクロールの方向．1が下向き，-1が上向き．
let s:direction = 1

function! s:smooth_scroll_countline(l, t, kind)
  let t_rate = 1.0 * a:t / s:n_time
  let Func = function('s:smooth_curve_' . a:kind)
  let l_rate = Func(t_rate)
  return s:direction * float2nr(1.0 * a:l * l_rate)
endfunction

function! s:smooth_curve_quadratic(r)
  return 1.0 * a:r * (2.0 - a:r)
endfunction

function! s:smooth_curve_linear(r)
  return 1.0 * a:r
endfunction

function! s:smooth_curve_cubic(r)
  return 1.0 * a:r * a:r * (3.0 - 2.0 * a:r)
endfunction

function! s:smooth_curve_quintic(r)
  return 1.0 * a:r * a:r * a:r * (6.0 * a:r * a:r - 15 * a:r + 10)
endfunction

function! s:tick(timer_id, forward_key, backward_key)
  let s:time += 1
  if s:time > s:n_time
    call timer_stop(s:timer_id)
    unlet s:timer_id
    let s:smooth_scroll_is_active = v:false
  else
    let nextpos = s:smooth_scroll_countline(abs(s:goal), s:time, g:smooth_scroll_scrollkind)
    let smooth_scroll_delta = nextpos - s:nowpos
    let s:nowpos = nextpos

    " Scroll
    if l:smooth_scroll_delta > 0
      execute "normal! " . string(abs(l:smooth_scroll_delta)) .. a:forward_key
    elseif l:smooth_scroll_delta < 0
      execute "normal! " . string(abs(l:smooth_scroll_delta)) .. a:backward_key
    else
      " Do nothing
    endif
  endif
endfunction

function! smooth_scroll#flick(nline, ntime, forward_key = "\<C-e>", backward_key = "\<C-y>", override = v:false)
  " 必要があれば mark を付ける
  if g:smooth_scroll_add_jumplist && !s:smooth_scroll_is_continuous
    normal! m`
  endif
  let s:smooth_scroll_is_continuous = v:true

  " scroll をアクティブにし、タイマーの時刻を初期化
  let s:smooth_scroll_is_active = v:true
  let s:time = 0
  let s:n_time = a:ntime

  if exists('s:timer_id') && a:override
    call timer_stop(s:timer_id)
    unlet s:timer_id
  endif

  if !exists('s:timer_id')
    " There is no thread, start one
    let s:goal = a:nline
    let s:nowpos = 0
    if s:goal == 0
      return
    endif
    let s:direction = s:goal / abs(s:goal)
    let l:interval = float2nr(round(g:smooth_scroll_interval))
    let fk = a:forward_key
    let bk = a:backward_key
    let s:timer_id = timer_start(l:interval, {id -> s:tick(id, fk, bk)}, {'repeat': -1})
  else
    " 既にタイマーが走っていたらそれを流用する
    let s:goal = a:nline + (s:goal - s:nowpos)
    let s:nowpos = 0
    if s:goal == 0
      call timer_stop(s:timer_id)
      unlet s:timer_id
      let s:smooth_scroll_is_active = v:false
    else
      let s:direction = s:goal / abs(s:goal)
    endif
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
