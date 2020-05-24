#################
smooth_scroll.vim
#################

vim における ``<C-f>, <C-b>, <C-d>, <C-u>`` のモーションを滑らかにするためのプラグインです．
yuttie さんの
`comfortable-motion.vim <https://github.com/yuttie/comfortable-motion.vim>`_
を参考にして作成しました．
指定した行数を指定した時間の間に移動することができます
（Vim の処理により多少遅延が発生することがあります）．

インストール
============

たとえば ``dein.vim`` を用いて TOML で管理する場合は ``dein.toml`` に以下のように記載します::

   [[plugins]]
   repo = 'monaqa/smooth-scroll.vim'

設定例
======

::

   let g:smooth_scroll_interval = 1000.0 / 60  " スクロール時間の単位 [ms]
   let g:smooth_scroll_no_default_key_mappings = 1 " <C-f> などを再定義したいとき

   " smooth_scroll#flick の引数には スクロール行数，スクロール時間，方向を指定
   " たとえば以下のように設定すると画面の行数分を 30 frame (= 500 ms) で移動する
   nnoremap <silent> <C-f> :call smooth_scroll#flick(winheight(0), 30,  1)<CR>
   nnoremap <silent> <C-b> :call smooth_scroll#flick(winheight(0), 30, -1)<CR>
   " たとえば以下のように設定すると画面の半分を 20 frame (~= 333 ms) で移動する
   nnoremap <silent> <C-d> :call smooth_scroll#flick(winheight(0) / 2, 20,  1)<CR>
   nnoremap <silent> <C-u> :call smooth_scroll#flick(winheight(0) / 2, 20, -1)<CR>

   " スクロールの仕方． linear, quadratic, cubic, quintic から指定（デフォルト：quadratic）
   " 次数を高めるほど速度の不連続点が減る
   let g:smooth_scroll_scrollkind = "cubic"

