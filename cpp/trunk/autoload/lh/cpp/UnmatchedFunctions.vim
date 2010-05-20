"=============================================================================
" $Id$
" File:		autoload/lh/cpp/UnmatchedFunctions.vim                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	14th Feb 2008
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	«description»
" 
"------------------------------------------------------------------------
" Installation:	«install details»
" History:	«history»
" TODO:		
" (*) Do not mess with history and @/
" (*) Support an update command
" }}}1
"=============================================================================

command! -nargs=1 FEcho :echo s:<args> 

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
function! lh#cpp#UnmatchedFunctions#verbose(level)
  let s:verbose = a:level
endfunction

function! s:Verbose(expr)
  if exists('s:verbose') && s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#UnmatchedFunctions#debug(expr)
  return eval(a:expr)
endfunction

" ## Menu {{{1
" ==========================[ Menu ]====================================
function! s:AddToMenu(lines, fns, kind)
  for fn in a:fns
    let line = fn.filename.'| No '.a:kind.' found for '
	  \. lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn)
    call add(a:lines, line)
  endfor
endfunction

function! s:BuildMenu(unmatched)
  let res = ['--abort--']
  call s:AddToMenu(res, a:unmatched.declarations, "definition")
  call s:AddToMenu(res, a:unmatched.definitions, "declaration")
  return res
endfunction

function! lh#cpp#UnmatchedFunctions#Display(className)
  let unmatched = lh#cpp#AnalysisLib_Function#SearchUnmatched(a:className)
  let choices = s:BuildMenu(unmatched)
  " return
  let b_id = lh#buffer#dialog#new(
	\ 'Unmatched('.substitute(a:className, '[^A-Za-z0-9_.]', '_', 'g' ).')',
	\ 'Unmatched functions for '.a:className,
	\ 'bot below',
	\ 0,
	\ 'lh#cpp#UnmatchedFunctions#select',
	\ choices
	\)
  " Added the lonely functions to the b_id
  let lUnmatched = unmatched.declarations 
  call extend(lUnmatched, unmatched.definitions)
  let b_id['unmatched'] = lUnmatched
  " Syntax and co
  call s:PostInitDialog()
  return ''
endfunction

function! s:PostInitDialog()
  if has("syntax")
    syn clear

    " syntax region UFNbOcc  start='^--' end='$' contains=UFNumber,UFName
    syntax match UFSignature /.*$/ contained
    syntax match UFFile /^  [^-][^|]\+/ contained nextgroup=UFText
    syntax match UFText /| No .* found for / contained nextgroup=UFSignature
    syntax region UFLine  start='^  [^-]' end='$' contains=UFFile,UFText,UFSignature

    syntax region UFExplain start='@' end='$' contains=UFStart
    syntax match UFStart /@/ contained
    syntax match Statement /--abort--/

    " Help
    highlight link UFExplain Comment
    highlight link UFStart Ignore

    " Lines
    highlight link UFLine Normal
    highlight link UFFile Directory
    highlight link UFText Normal
    highlight link UFSignature Identifier
  endif
endfunction

function! lh#cpp#UnmatchedFunctions#select(results)
  if len(a:results.selection) > 1
    " this is an assert
    throw "Functions-Matcher: We are not supposed to select several functions"
  endif
  let selection = a:results.selection[0]
  if selection == 0 | call lh#buffer#dialog#quit() | return | endif
  " let unmatched = b:dialog.unmatched
  " let cmd = b:cmd

  let choices = a:results.dialog.choices
  echomsg '-> '.choices[selection]
  " echomsg '-> '.info[selection-1].filename . ": ".info[selection-1].cmd
  if exists('s:quit') | :quit | endif
  " 
  let selected_unmatched = a:results.dialog.unmatched[selection-1]
  call lh#buffer#find(selected_unmatched.filename)
  normal! gg
  try
    " todo: save history and @/
    let save_magic = &magic
    set nomagic
    exe selected_unmatched.cmd
  finally
    let &magic = save_magic
  endtry
endfunction

" ==========================[ Highlight ]===============================
" @todo
" Active HL in buffers where there are unmatched functions decl/def
"
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
