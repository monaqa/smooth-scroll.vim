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
if !exists('g:smooth_scroll_interval')
  let g:smooth_scroll_interval = 1000.0 / 60
endif
if !exists('g:smooth_scroll_scrollkind')
  let g:smooth_scroll_scrollkind = "quadratic"
endif
if !exists('g:smooth_scroll_scroll_down_key')
  let g:smooth_scroll_scroll_down_key = "j"
endif
if !exists('g:smooth_scroll_scroll_up_key')
  let g:smooth_scroll_scroll_up_key = "k"
endif

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

" 
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

" 
function! s:tick(timer_id)
  let s:time += 1
  if s:time > s:n_time
    call timer_stop(s:timer_id)
    unlet s:timer_id
  else
    let nextpos = s:smooth_scroll_countline(abs(s:goal), s:time, g:smooth_scroll_scrollkind)
    let smooth_scroll_delta = nextpos - s:nowpos
    let s:nowpos = nextpos

    " Scroll
    if l:smooth_scroll_delta > 0
      execute "normal! " . string(abs(l:smooth_scroll_delta)) . g:smooth_scroll_scroll_down_key
    elseif l:smooth_scroll_delta < 0
      execute "normal! " . string(abs(l:smooth_scroll_delta)) . g:smooth_scroll_scroll_up_key
    else
      " Do nothing
    endif
  endif
  " let l:st = s:smooth_scroll_state  " This is just an alias for the global variable
  " if abs(l:st.velocity) >= 1 || l:st.impulse != 0 " short-circuit if velocity is less than one
  "   let l:dt = g:smooth_scroll_interval / 1000.0  " Unit conversion: ms -> s
  "
  "   " Compute resistance forces
  "   let l:vel_sign = l:st.velocity == 0
  "    \            ? 0
  "    \            : l:st.velocity / abs(l:st.velocity)
  "   let l:friction = -l:vel_sign * g:smooth_scroll_friction * 1  " The mass is 1
  "   let l:air_drag = -l:st.velocity * g:smooth_scroll_air_drag
  "   let l:additional_force = l:friction + l:air_drag
  "
  "   " Update the state
  "   let l:st.delta += l:st.velocity * l:dt
  "   let l:st.velocity += l:st.impulse + (abs(l:additional_force * l:dt) > abs(l:st.velocity) ? -l:st.velocity : l:additional_force * l:dt)
  "   let l:st.impulse = 0
  "
  "   " Scroll
  "   let l:int_delta = float2nr(l:st.delta >= 0 ? floor(l:st.delta) : ceil(l:st.delta))
  "   let l:st.delta -= l:int_delta
  "   if l:int_delta > 0
  "     execute "normal! " . string(abs(l:int_delta)) . g:smooth_scroll_scroll_down_key
  "   elseif l:int_delta < 0
  "     execute "normal! " . string(abs(l:int_delta)) . g:smooth_scroll_scroll_up_key
  "   else
  "     " Do nothing
  "   endif
  "   redraw
  " else
  "   " Stop scrolling and the thread
  "   let l:st.velocity = 0
  "   let l:st.delta = 0
  "   call timer_stop(s:timer_id)
  "   unlet s:timer_id
  " endif
endfunction

function! smooth_scroll#flick(nline, ntime, direction)
    let s:time = 0
    let s:n_time = a:ntime
  if !exists('s:timer_id')
    " There is no thread, start one
    let s:nowpos = 0
    let s:direction = a:direction
    let s:goal = a:nline * a:direction
    let l:interval = float2nr(round(g:smooth_scroll_interval))
    let s:timer_id = timer_start(l:interval, function("s:tick"), {'repeat': -1})
  else
    let s:goal = a:nline * a:direction + (s:goal - s:nowpos)
    let s:nowpos = 0
    if s:goal == 0
      call timer_stop(s:timer_id)
      unlet s:timer_id
    else
      let s:direction = abs(s:goal) / s:goal
    end
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
