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

" The time
let s:smooth_scroll_time = 0
let s:smooth_scroll_nline = 80
let s:smooth_scroll_ntime = 20
let s:smooth_scroll_direction = 1

function! s:smooth_scroll_linear(t)
  let nline = s:smooth_scroll_nline
  let ntime = s:smooth_scroll_ntime
  let direc = s:smooth_scroll_direction
  return direc * float2nr(nline / ntime * a:t)
endfunction


function! s:tick(timer_id)

  let s:smooth_scroll_time += 1
  if s:smooth_scroll_time > s:smooth_scroll_ntime
    call timer_stop(s:timer_id)
    unlet s:timer_id
  else
    let smooth_scroll_pos_now = s:smooth_scroll_linear(s:smooth_scroll_time - 1)
    let smooth_scroll_pos_next = s:smooth_scroll_linear(s:smooth_scroll_time)
    let smooth_scroll_delta = smooth_scroll_pos_next - smooth_scroll_pos_now

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
  let s:smooth_scroll_time = 0
  let s:smooth_scroll_nline = a:nline
  let s:smooth_scroll_ntime = a:ntime
  let s:smooth_scroll_direction = a:direction
  if !exists('s:timer_id')
    " There is no thread, start one
    let l:interval = float2nr(round(g:smooth_scroll_interval))
    let s:timer_id = timer_start(l:interval, function("s:tick"), {'repeat': -1})
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
