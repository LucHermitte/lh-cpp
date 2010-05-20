"=============================================================================
" $Id$
" File:		ftplugin/cpp/idl_set.vim                                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	09th Mar 2005
" Last Update:	$Date$ (09th Mar 2005)
"------------------------------------------------------------------------
" Description:	Few definitions for IDL editing.
" 
"------------------------------------------------------------------------
" Installation:	Drop the file into {rtp}/ftplugin/
" History:	
" 	v1.0: first version
" 		inspired from ftplugin/c/c_set.vim and ftplugin/cpp/cpp_set.vim
" TODO:		
" 	* Ensure Def_MapC from c_set.vim is loaded
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists('b:loaded_ftplug_idl_set_vim')
       \ && !exists('g:force_reload_idl_set_vim')
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_idl_set_vim = 1


" ------------------------------------------------------------------------
" VIM Includes {{{2
" ------------------------------------------------------------------------
if exists("b:did_ftplugin")
  unlet b:did_ftplugin
endif
 
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1

" ------------------------------------------------------------------------
" Options to set {{{2
" ------------------------------------------------------------------------
setlocal formatoptions=croql
setlocal cindent
setlocal comments=sr:/*,mb:*,exl:*/,://
setlocal isk+=#		" so #if is considered as a keyword, etc

setlocal ch=2
setlocal nosmd
setlocal cinoptions=g0,t0,h1s

if !exists('maplocalleader')
  let maplocalleader = ','
endif

runtime syntax/doxygen.vim

runtime ftplugin/c/c_brackets.vim

" ------------------------------------------------------------------------
" Comments ; Javadoc/DOC++/Doxygen style {{{2
" ------------------------------------------------------------------------
" /**       inserts /** <cursor>
"                    */
" but only outside the scope of C++ comments and strings
  inoremap <buffer> /**  <c-r>=Def_MapC('/**',
	\ '/**\<cr\>\<BS\>/\<up\>\<end\> ',
	\ '/**\<cr\>\<BS\>/!mark!\<up\>\<end\> ')<cr>
" /*<space> inserts /** <cursor>*/
  inoremap <buffer> /*<space>  <c-r>=Def_MapC('/* ',
	\ '/** */\<left\>\<left\>',
	\ '/** */!mark!\<esc\>F*i')<cr>
 
" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_idl_set_vim") 
      \ && !exists('g:force_reload_idl_set_vim')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_idl_set_vim = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
