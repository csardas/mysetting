set noautoindent
syntax on
set showcmd
set nocp
:set noeb

set softtabstop=4
set shiftwidth=4


"if has("multi_byte")
" set encoding=utf-8
" setglobal fileencoding=big5
" set fileencoding=big5
" set bomb
" set termencoding=big5
" set fileencodings=ucs-bom,big5,utf-8,latin1
"" set guifont=-misc-fixed-medium-r-normal-*-18-120-100-100-c-90-iso10646-1
"" set guifontwide=-misc-fixed-medium-r-normal-*-18-120-100-100-c-180-iso10646-1
"else
"   echoerr "Sorry, this version of (g)vim was not compiled with multi_byte"
"endif
"
"
" UTF8¤¤¤å
" è¨­å????????è½?????? UTF-8 ç·¨ç¢¼
 set fileencodings=utf-8,big5,euc-jp,gbk,euc-kr,utf-bom,iso8859-1
 set encoding=utf8
 set tenc=utf8
" ä½¿ç???? <F12> ä¾??å°????å­??ç·¨ç¢¼è½?????? Big5
 map <F12> :set tenc=big5<cr>

" We know xterm-debian is a color terminal
 if &term =~ "xterm-debian" || &term =~ "xterm-xfree86" || &term =~ "xterm" || &term =~ "mlterm"
   set t_Co=16
   set t_Sf=^[[3%dm
   set t_Sb=^[[4%dm
 endif


"change color
hi Comment ctermfg=lightgreen
"hi Comment ctermbg=darkgrey

" possible cterm colors:
" black, blue, cyan, gray, green, magenta, red, white, yellow

" Tab completion
" Tab completion of tags/keywords if not at the beginning of the
" line.  Very slick.
function InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
" end tab completion

