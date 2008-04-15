"=============================================================================
" $Id$
" File:		c_localleader.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.0
" Created:	14th Apr 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	ftplugin for setting localleader in C (-like) programming
" 
"------------------------------------------------------------------------
" Installation:	�install details�
" History:	�history�
" TODO:		�missing features�
" }}}1
"=============================================================================

" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if exists("b:loaded_ftplug_c_localleader") && !exists('g:force_reload_ftplug_c_localleader')
  finish
endif
" Avoid local reinclusion }}}2

"------------------------------------------------------------------------
"  The definition {{{2

if !exists('maplocalleader')
  let maplocalleader = ','
endif

"=============================================================================
" vim600: set fdm=marker:
