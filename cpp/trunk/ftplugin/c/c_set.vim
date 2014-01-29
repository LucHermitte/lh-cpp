" ========================================================================
" $Id$
" File:		ftplugin/c/c_set.vim
" Author:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Last Update:	$Date$
"
" Purpose:	ftplugin for C (-like) programming
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependancies:
" 		LoadHeaderFile.vim	
" 		flist & flistmaps.vim	-- Dr Chips
" 		VIM >= 6.00 only
" ========================================================================

" 4 log:
" 14th Apr 2007: &isk-=-
" for changelog: 02nd Jun 2006 -> suffixesadd


" ========================================================================
" Buffer local definitions {{{1
" ========================================================================
if exists("b:loaded_c_set") && !exists('g:force_reload_c_set')
  finish 
endif
let b:loaded_c_set = 1
let s:cpo_save = &cpo
set cpo&vim

" ------------------------------------------------------------------------
" Includes {{{
" ------------------------------------------------------------------------
source $VIMRUNTIME/ftplugin/c.vim
let b:did_ftplugin = 1
" }}}
" ------------------------------------------------------------------------
" Options to set {{{
" ------------------------------------------------------------------------
" Note: these options can be overrided into a ftplugin placed in an after/
" directory.
"
setlocal formatoptions=croql
setlocal cindent
setlocal cinoptions=g0,t0
setlocal define=^\(#\s*define\|[a-z]*\s*const\s*[a-z]*\)
setlocal comments=sr:/*,mb:*,exl:*/,:///,://
setlocal isk+=#		" so #if is considered as a keyword, etc
setlocal isk-=-		" so ptr- (in ptr->member) is not
setlocal isk-=<
setlocal isk-=>
setlocal isk-=:
setlocal suffixesadd+=.h,.c

setlocal cmdheight=3
setlocal nosmd

" Dictionary from Dr.-Ing. Fritz Mehner 
let s:dictionary=expand("<sfile>:p:h").'/word.list'
if filereadable(s:dictionary)
  let &dictionary=s:dictionary
  setlocal complete+=k
endif
setlocal complete-=i
" }}}
" ------------------------------------------------------------------------
" File loading {{{
" ------------------------------------------------------------------------
"
" Things on :A and :AS
""so $VIM/macros/a.vim
"
""so <sfile>:p:h/LoadHeaderFile.vim
if exists("*LoadHeaderFile")
  nnoremap <buffer> <buffer> <C-F12> 
	\ :call LoadHeaderFile(getline('.'),0)<cr>
  inoremap <buffer> <buffer> <C-F12> 
	\ <esc>:call LoadHeaderFile(getline('.'),0)<cr>
endif

" flist (Dr Chips)
""so <sfile>:p:h/flistmaps.vim
if filereadable(expand("hints"))
  au BufNewFile,BufReadPost *.h,*.ti,*.inl,*.c,*.C,*.cpp,*.CPP,*.cxx
	\ so hints<CR>
endif

" }}}
" ------------------------------------------------------------------------
"}}}1
" ========================================================================
let &cpo = s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
