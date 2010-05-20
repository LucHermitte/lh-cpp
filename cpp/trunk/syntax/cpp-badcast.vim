"=============================================================================
" $Id$
" File:		syntax/cpp-badcatch.vim                                    {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	29th Jun 2006
" Last Update:	$Date$
"------------------------------------------------------------------------
" Purpose:	C++ syntax enhancements
" 	(*) Hightlights catches made by-value instead of by-reference.
" 	(*) Defines the two mappings [b (/resp. ]b) to jump to the previous
" 	    (/resp. next) catch made by value.
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" 	Installation Method:
" 		Define a {rtp}/syntax/c.vim (where {rtp} < $VIMRUNTIME) that
" 		contains:
"		    " This is the only valid way to load the C++ and C default syntax file.
"		    so $VIMRUNTIME/syntax/c.vim
"		    " Source C hooks
"		    runtime! syntax/c-*.vim syntax/c_*.vim
"
" Requirements:
" 	word_tools.vim::GetCurrentKeyword()	-- unchecked
"
" Option:
" 	- |cpp_no_bad_by_reference| to disable the check that catches are done
" 	by reference.
" TODO:
"	- "typename" should be supported like "const"
" 	- bug fix: do not highlight "catch ([[:space:]] const foo<cursor>)"
" }}}1
" ========================================================================
" {{{1 Syntax definitions
"
" {{{2 Enforce catch by reference
if !exists("cpp_no_catch_by_reference")

  " In C++, we should always catch by reference (and throw by value)
  "
  " - "constains=cStorageClass" is used to accept and highlight "const"
  " - "\(regex\)\@<=" is used to exclude a (required) leading context, optional
  "   closing spaces are better outside the context
  "   "\(regex\)\@=" is used to exclude a (required) closing context
  " - The complex BadCatch regex tells to match an expression without "&" except "...".
  "
  " @todo 
  " - catch ([[:space:]]const foo <+cursor+>) is not recognized as a
  "   cppEditedCatch, but a cppBadCatch
  " syn match cppBadCatch    /\(catch\s*(\s*\(const\)\=\)\@<=\(\s*\.\.\.\s*\)\@![^&)]*\()\)\@=/ contains=cStorageClass
  syn match cppBadCatch    /\(catch\s*(\)\@<=\(\s*\.\.\.\s*\)\@![^&)]*\()\)\@=/ contains=cStorageClass
  " syn match cppBadCatch    /\(catch\s*(\s*const\)\@<=\(\s*\.\.\.\s*\)\@![^&)]*\()\)\@=/ contains=cStorageClass

  " Accept what is currently typed
  " catch(foo^) catch(foobar  ^) catch(foobar con^) catch(foobar const ^) ...
  syn match cppEditedCatch /\(catch\s*(\)\@<=\s*[a-zA-Z:_]\+\s*\(\%[const]\|const\s*\)\=\%#\(\s*)\)\@=/ contains=cStorageClass

  " syn match cppEditedCatch /\(catch\s*(\)\@<=\s*[a-zA-Z:_]*\s*\%#\(\s*)\)\@=/
  syn match cppEditedCatch /\(catch\s*(\s*const\)\@<=\s*[a-zA-Z:_]*\s*\%#\(\s*)\)\@=/ contains=cStorageClass
  " syn match cppEditedCatch /\(catch\s*(\s*\(const\s*\)\=\)\@<=\(\%[const]\s*\|const\s*[a-zA-Z:_]\+\s*\)\%#\(\s*)\)\@=/

  " syn match cppEditedCatch /\(catch\s*(\s*\(const\s*\)\=\)\@<=[a-zA-Z:_]\+\s*\(\%[const]\|const\s*\)\=\%#\(\s*)\)\@=/

  hi def link cppBadCatch    SpellBad
  hi def link cppEditedCatch SpellRare
endif


" ========================================================================
" {{{1 Some mappings
if exists('b:cpp_bad_catch_loaded') && !exists('g:force_reload_cpp_bad_catch')
  finish
endif
let b:cpp_bad_catch_loaded = 1

nnoremap <silent> <buffer> ]b :call <sid>NextBadCatch()<cr>
nnoremap <silent> <buffer> [b :call <sid>PrevBadCatch()<cr>

" ========================================================================
" {{{1 Some functions
if exists('g:cpp_bad_catch_loaded') && !exists('g:force_reload_cpp_bad_catch')
  finish
endif
let g:cpp_bad_catch_loaded = 1

" {{{2 Constants
let s:k_badCatch    = "cppBadCatch"
let s:k_badCatchGID = hlID(s:k_badCatch)
let s:k_trans       = 1

" {{{2 Tells if the cursor in on a bad catch
function! s:IsInBadCatch()
  let res = synID(line("."),col("."),s:k_trans) == s:k_badCatchGID
  return res
endfunction

" {{{2 Find next or previous bad catch
" @param {direction} = ""  => next
"                    = "b" => previous
function! s:FindNextOrPrev(direction)
  let r = 0
  while r != 1
    let r = search('\<catch\_s*(\zs', 'W'.a:direction)
    " No more catch => fail!
    if r == 0 | return 0 | endif

    let r = s:IsInBadCatch()
  endwhile
  " assert r == 1
  return 1
endfunction

" {{{2 Next bad catch
function! s:NextPrevBadCatchImpl(moveWhenOnBadCatch, moveWhenNotOnBadCatch, searchDirection)
  " Remember where the search started
  let pos = line('.').'normal! '.virtcol('.').'|'

  " if the cursor is on a bad catch, go out of the catch declaration
  " or if the current keyword is "const" (as s:IsInBadCatch() won't work
  " correctly on "const" ; expand('<cword>') doesn't return anything useful
  if s:IsInBadCatch() || GetCurrentKeyword() == "const"
    " goto end of line if the cursor is on a badcatch
    silent! exe "normal! ".a:moveWhenOnBadCatch
  else
    " else goto next word
    silent! exe "normal! ".a:moveWhenNotOnBadCatch
  endif

  if !s:FindNextOrPrev(a:searchDirection)
    exe pos
    call s:ErrorMsg ('No other catch() by value found')
    return 0
  else
    call s:GotoWhereAmpersandIsMissing()
    return 1
  endif
endfunction

function! s:NextBadCatch()
  return s:NextPrevBadCatchImpl('$', 'w', '')
endfunction

function! s:PrevBadCatch()
  return s:NextPrevBadCatchImpl('0', 'b', 'b')
endfunction


" {{{2 Error Message
function! s:ErrorMsg(msg)
  if has('gui')
    call confirm(a:msg, '&Ok', 1, 'Error')
  else
    echohl ErrorMsg
    echo a:msg
    echohl None
  endif
endfunction

" {{{2 GotoWhereAmpersandIsMissing
function! s:GotoWhereAmpersandIsMissing()
  " Move the cursor where the ampersand ("&") should be inserted
  let last_line = line('.')
  let pos = last_line.'normal! '.virtcol('.').'|'
  " move to start of line
  normal! 0
  " if const, move after the const
  if     search('(\s*[A-Za-z_:]\+\s*const\zs') == last_line " found!
    " do nothing, it ok
  else
    " reset position
    exe last_line
    normal! 0
    if search('(\s*\(const\s*\)\=[A-Za-z_:]\+\zs') == last_line " found!
      " do nothing, it ok
    else 
    " reset position
      exe pos
    endif
  endif
endfunction

" {{{2 Old implementations
" {{{3 Next bad catch
function! s:NextBadCatch0()
  " if the cursor is on a bad catch, go out of the catch declaration
  if synID(line("."),col("."),1) == s:k_badCatchGID
    " goto next line if the cursor is on a badcatch
    silent normal! j
  else
    " else goto next word
    silent! norm! w
  endif

  if LHNextHighlight(s:k_badCatch, 1) == 0
    call s:ErrorMsg ('No other catch() by value found')
    return 0
  else
    call s:GotoWhereAmpersandIsMissing()
    return 1
  endif
endfunction

" {{{3 Previous bad catch
function! s:PrevBadCatch0()
  " if the cursor is on a bad catch, go out of the catch declaration
  if synID(line("."),col("."),1) == hlID(s:k_badCatch)
    " goto start of line if the cursor is on a badcatch
    silent normal! 0
  else
    " else goto prev word
    silent! norm! b
  endif

  if LHPrevHighlight(s:k_badCatch, 1) == 0
    call s:ErrorMsg ('No other catch() by value found')
    return 0
  else
    call s:GotoWhereAmpersandIsMissing()
    return 1
  endif
endfunction

" ========================================================================
" vim: set foldmethod=marker:
