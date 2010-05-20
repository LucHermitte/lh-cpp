"=============================================================================
" $Id$
" File:		syntax/cpp-throw-spec.vim                                 {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	06th Sep 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
" Purpose:	C++ syntax enhancements
" 	(*) Hightlights throw specifications
" 	(*) Defines the two mappings [t (/resp. ]t) to jump to the previous
" 	    (/resp. next) throw specification.
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
" }}}1
"=============================================================================

" ========================================================================
" {{{1 Syntax definitions
"
" {{{2 Enforce no throw specifications
if !exists("cpp_no_hl_throw_spec")

  " In C++, throw specifications does not do what most C++ developpers think
  " they do. Instead of enforcing a static verification on exceptions flows,
  " they embed in the result binary some code that checks that the exceptions 
  " thrown from a function match the authorized exceptions. If not, the
  " application will crash (if the exception handler has not been overriden).
  " In all cases the application can't do anything but halt very soon. They can
  " be seen as some kind of assertions, except they are always active, even in
  " "release" binaries. 

  " Considered this is a tricky feature of C++, and considered they are hardly
  " useful, here is this script that highlight them as "misspellings".

  " As nevetheless some framework require them, it will be possible to
  " configure a list of authorized familly of exception specifications.
  if ! exists('g:cpp_throw_spec_ignore')
    let g:cpp_throw_spec_ignore = [ 'CORBA' ]
  endif

  silent! syn clear cppThrowSpec
  silent! syn clear cppThrowSpecIgnored

  " Method 2, that has the same result... (throw is not underlined)
  syn match cppThrowSpec /\(throw\_s*\)\@<=(\_.\{-})/
  exe 'syn match cppThrowSpecIgnored /\(throw\_s*\)\@<=(\_[^)]*\('.join(g:cpp_throw_spec_ignore, '\|').'\)\_[^)]*)/'

  hi def link cppThrowSpec SpellBad
  hi def link cppThrowSpecIgnored SpellRare
endif

" ========================================================================
" {{{1 Some mappings
if exists('b:cpp_throw_spec_loaded') && !exists('g:force_reload_cpp_throw_spec')
  finish
endif
let b:cpp_throw_spec_loaded = 1

nnoremap <silent> <buffer> ]t :call <sid>NextThrowSpec()<cr>
nnoremap <silent> <buffer> [t :call <sid>PrevThrowSpec()<cr>

" {{{1 Some functions
if exists('g:cpp_throw_spec_loaded') && !exists('g:force_reload_cpp_throw_spec')
  finish
endif
let g:cpp_throw_spec_loaded = 1

" {{{2 Constants
let s:k_throwSpec    = "cppThrowSpec"
let s:k_throwSpecGID = hlID(s:k_throwSpec)
let s:k_trans       = 1

" {{{2 Tells if the cursor in on a bad catch
function! s:IsInThrowSpec()
  let res = synID(line("."),col("."),s:k_trans) == s:k_throwSpecGID
  return res
endfunction

" {{{2 Find next or previous bad catch
" @param {direction} = ""  => next
"                    = "b" => previous
function! s:FindNextOrPrev(direction)
  let r = 0
  while r != 1
    let r = search('\<throw\_s*(\zs', 'W'.a:direction)
    " No more catch => fail!
    if r == 0 | return 0 | endif

    let r = s:IsInThrowSpec()
    if r == 1
      call search('\<throw\_s*(', 'Wb') " beacause of \zs + s:IsInThrowSpec() test
    endif
  endwhile
  " assert r == 1
  return 1
endfunction

" {{{2 Next bad catch
function! s:NextPrevThrowSpecImpl(moveWhenOnThrowSpec, moveWhenNotOnThrowSpec, searchDirection)
  " Remember where the search started
  let pos = line('.').'normal! '.virtcol('.').'|'

  if 1
  " if the cursor is on a bad catch, go out of the catch declaration
  " or if the current keyword is "const" (as s:IsInThrowSpec() won't work
  " correctly on "const" ; expand('<cword>') doesn't return anything useful
  " if s:IsInThrowSpec() || GetCurrentKeyword() == "throw"
  if s:IsInThrowSpec() || expand('<cword>') == "throw"
    " goto end of line if the cursor is on a throwspec
    silent! exe "normal! ".a:moveWhenOnThrowSpec
  else
    " else goto next word
    silent! exe "normal! ".a:moveWhenNotOnThrowSpec
  endif
  endif

  if !s:FindNextOrPrev(a:searchDirection)
    exe pos
    call s:ErrorMsg ('No other throw-specification found')
    return 0
  else
    return 1
  endif
endfunction

function! s:NextThrowSpec()
  return s:NextPrevThrowSpecImpl("/)/\<cr>", 'w', '')
endfunction

function! s:PrevThrowSpec()
  return s:NextPrevThrowSpecImpl('0', 'b', 'b')
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


"------------------------------------------------------------------------
"=============================================================================
" vim600: set fdm=marker:
