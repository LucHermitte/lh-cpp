" ========================================================================
" $Id$
" File:		syntax/c.vim
" Author:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Last Update:	$Date$
"
" Purpose:	C syntax enhancements
" Option:
" ========================================================================

" This is the only valid way to load the C++ and C default syntax file.
so $VIMRUNTIME/syntax/c.vim

" Source syntax hooks for C
runtime! syntax/c-*.vim syntax/c_*.vim

