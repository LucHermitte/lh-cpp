"=============================================================================
" $Id$
" File:		autoload/lh/cpp/brackets.vim                             {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	17th Mar 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	Functions that tune how some bracket characters should expand in C&C++
" 
"------------------------------------------------------------------------
" Installation:	
" 	Requires Vim7+ and lh-map-tools
" 	Used by {ftp}/ftplugin/c/c_brackets.vim
" 	Drop this file into {rtp}/autoload/lh/cpp
"
" History:	
" 	v1.0.0: First version
"	v2.0.0: License GPLv3 w/ extension
" TODO:	
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------

" Callback function that specializes the behaviour of '<'
function! lh#cpp#brackets#lt()
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ '^#\s*include\s*$'
	\ . '\|\U\{-}_cast\s*$'
	\ . '\|template\s*$'
	\ . '\|typename[^<]*$'
	" \ . '\|\%(lexical\|dynamic\|reinterpret\|const\|static\)_cast\s*$'
    if exists('b:usemarks') && b:usemarks
      return '<!cursorhere!>!mark!'
      " NB: InsertSeq with "\<left>" as parameter won't work in utf-8 => Prefer
      " "h" when motion is needed.
      " return '<>' . "!mark!\<esc>".lh#encoding#strlen(Marker_Txt())."hi"
      " return '<>' . "!mark!\<esc>".lh#encoding#strlen(Marker_Txt())."\<left>i"
    else
      " return '<>' . "\<Left>"
      return '<!cursorhere!>'
    endif
  else
    return '<'
  endif
endfunction




"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
