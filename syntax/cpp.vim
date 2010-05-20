" ========================================================================
" $Id$
" File:		syntax/cpp.vim
" Author:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Last Update:	$Date$
"
" Purpose:	C++ syntax enhancements
"
" Option:
" ========================================================================

" This is the only valid way to load the C++ and C default syntax file.
so      $VIMRUNTIME/syntax/cpp.vim


" Source syntax hooks for C++
runtime! syntax/cpp-*.vim syntax/cpp_*.vim

" Load syntax enhancements for Doxygen, if installed
" runtime syntax/doxygen.vim
" see :h doxygen 
" .vimrc => :let g:load_doxygen_syntax=1

" Load syntax enhancements for wxWindows, if installed
runtime syntax/wxwin.vim
