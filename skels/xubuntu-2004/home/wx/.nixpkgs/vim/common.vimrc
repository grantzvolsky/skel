filetype indent off
set backspace=indent,eol,start
setl noai nocin nosi inde=
set background=dark
set expandtab shiftwidth=2 softtabstop=2 tabstop=2
set hlsearch
set noswapfile
set nowrap

nmap <Esc>t :terminal ++curwin<CR>

tmap <Esc>h <C-w>h
tmap <Esc>j <C-w>j
tmap <Esc>k <C-w>k
tmap <Esc>l <C-w>l
tmap <C-j> <C-\><C-N>:resize +1<CR>a
tmap <C-k> <C-\><C-N>:resize -1<CR>a
tmap <C-l> <C-\><C-N>:vertical resize +1<CR>a
tmap <C-h> <C-\><C-N>:vertical resize -1<CR>a

nmap <C-w>- :sp<CR>
nmap <C-j> :resize +1<CR>
nmap <C-k> :resize -1<CR>
nmap <C-w><Bar> :vsp<CR>
nmap <C-l> :vertical resize +1<CR>
nmap <C-h> :vertical resize -1<CR>
nmap <S-Tab> :b#<CR>
nnoremap <C-F7> :tabp<CR>
nnoremap <C-F8> :tabn<CR>
nnoremap <F7> :bp<CR>
nnoremap <F8> :bn<CR>
nnoremap <M-p> :FZF<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <F9> :Lines<CR>
nnoremap <F10> :Rg<CR>
nnoremap <C-b> :Buffers<CR>
"nnoremap <Esc>b :Buffers<CR>
