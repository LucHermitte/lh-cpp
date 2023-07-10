" ========================================================================
" File:         ftplugin/cpp/cpp_set.vim                              {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0
" Last Update:  01st Dec 2022
"
"------------------------------------------------------------------------
" Description:
"       Defines vim options for C++ programming.
" }}}1
" ========================================================================

" for changelog: 02nd Jun 2006 -> suffixesadd

" ========================================================================
" Buffer local definitions {{{1
" ========================================================================
if exists("b:loaded_local_cpp_settings") && !exists('g:force_reload_cpp_set')
  finish
endif
let b:loaded_local_cpp_settings = 1

"" line continuation used here ??
let s:cpo_save = &cpo
set cpo&vim

" ------------------------------------------------------------------------
" Commands {{{2
" ------------------------------------------------------------------------
" Cf. cpp_BuildTemplates.vim
"
" ------------------------------------------------------------------------
" VIM Includes {{{2
" ------------------------------------------------------------------------
if exists("b:did_ftplugin")
  unlet b:did_ftplugin
endif
source $VIMRUNTIME/ftplugin/cpp.vim
let b:did_ftplugin = 1

"
" ------------------------------------------------------------------------
" Options to set {{{2
" ------------------------------------------------------------------------
"  setlocal formatoptions=croql
"  setlocal cindent
"
setlocal cinoptions=g0,t0,h1s,i0
if has('patch-7.3.202')
  setlocal cinoptions+=N-s
endif
setlocal suffixesadd+=.hpp,.cpp,.C,.h++,.c++,.hh

" Emulate [[ and ]] in C++
nnoremap <silent> <buffer> [[ :call lh#dev#_goto_function_begin()<cr>
onoremap <silent> <buffer> [[ :<c-u>call lh#dev#_goto_function_begin()<cr>
nnoremap <silent> <buffer> ][ :call lh#dev#_goto_function_end()<cr>
onoremap <silent> <buffer> ][ :<c-u>call lh#dev#_goto_function_end()<cr>

" browse filter
if has("gui_win32")
  let b:browsefilter =
        \ "C++ Header Files (*.hpp *.h++ *hh)\t*.hpp;*.h++;*.hh\n" .
        \ "C++ Source Files (*.cpp *.c++)\t*.cpp;*.c++\n" .
        \ "C Header Files (*.h)\t*.h\n" .
        \ "C Source Files (*.c)\t*.c\n" .
        \ "All Files (*.*)\t*.*\n"
endif
" }}}2

" ========================================================================
" General definitions {{{1
" ========================================================================
if exists("g:loaded_cpp_set") && !exists('g:force_reload_cpp_ftp')
  let &cpo = s:cpo_save
  finish
endif
let g:loaded_cpp_set = 1

let &cpo = s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
