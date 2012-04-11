"=============================================================================
" $Id$
" File:		fold/c-fold.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	06th Jan 2005
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:
"       Simplified version of c-fold in order to speed-up the computations.
"       => we fold on indent.
"------------------------------------------------------------------------
" }}}1
"=============================================================================

"------------------------------------------------------------------------

setlocal foldmethod=indent

"=============================================================================
" vim600: set fdm=marker:
