" ========================================================================
" $Id$
" File:		ftplugin/cpp/cpp_InsertAccessors.vim                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Last Change:	$Date$ (28th July 2003)
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
"
"------------------------------------------------------------------------
" Description:	
" 	Defines a function to insert const-correct accessors and mutators.
"
" 	Used in cpp_BuildTemplates.vim
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
"       Drop this file into {rtp}/ftplugin/cpp
"       Requires Vim7+, lh-cpp, lh-dev
" Options:	cf. lh_dev
"
" TODO:		{{{2
"  * Clean up the inline file generated when mu-template is installed.
"  * Better place the members in respect of the different options.
"  * Extend the accessors feature to any member, and jump from a definition to
"    an implementation, and vice-versa.
"  * Use Cpp_FileExtensionXXX()
"  * Understand const, mutable, volatile as particular type specifiers ; and
"    then adapt the accessors : for instance, a const data can't have a
"    reference accessor ; a reference attribute must be defined in the
"    constructor (no parameter-less constructor), ...
"  * Do something about the pimpl idiom.
"  * g:BooleanAccessorPrefix -> "is" or ""
" }}}1
" ==========================================================================

let s:k_version = 200
" Buffer-local Definitions {{{1
" Avoid local reinclusion {{{2
if &cp || (exists("b:loaded_ftplug_cpp_InsertAccessors")
      \ && (b:loaded_ftplug_cpp_InsertAccessors >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_InsertAccessors'))
  finish
endif
let b:loaded_ftplug_cpp_InsertAccessors = s:k_version
let s:cpo_save=&cpo
set cpo&vim
" Avoid local reinclusion }}}2

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_cpp_InsertAccessors")
      \ && (g:loaded_ftplug_cpp_InsertAccessors >= s:k_version)
      \ && !exists('g:force_reload_ftplug_cpp_InsertAccessors'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_cpp_InsertAccessors = s:k_version
" Avoid global reinclusion }}}2
"------------------------------------------------------------------------
" Constants {{{2
let s:k_accessor_comment_attribute = '/** %a ... */'
let s:k_accessor_comment_get       = '/** Get accessor to %a */'
let s:k_accessor_comment_set       = '/** Set accessor to %a */'
let s:k_accessor_comment_proxy_get = '/** Proxy-Get accessor to %a */'
let s:k_accessor_comment_proxy_set = '/** Proxy-Set accessor to %a */'
let s:k_accessor_comment_ref       = '/** Ref. accessor to %a */'
let s:k_accessor_comment_proxy_ref = '/** Proxy-Ref. accessor to %a */'

"------------------------------------------------------------------------
" Functions {{{2
" Note: most filetype-global functions are best placed into
" autoload/«your-initials»/cpp/«cpp_InsertAccessors».vim
" Keep here only the functions are are required when the ftplugin is
" loaded, like functions that help building a vim-menu for this
" ftplugin.

" Insertion of accessors {{{3

" Function: s:InsertLines(lines) "{{{4
function! s:InsertLines(lines)
  silent put = a:lines
  silent '[,']normal! ==
endfunction

" Function: s:WriteAccessor	{{{4
function! s:WriteAccessor(returnType, signature, instruction, comment)
  try 
    let old_foldenable = &foldenable
    set nofoldenable
    let lines = []
    let lines += [a:comment]
    if '' != a:instruction
      let curly = lh#cpp#option#nl_before_curlyB() ? "" : "\<tab>{"
      if a:returnType =~ "^inline"
        let lines += ['inline']
        let lines += [ substitute(a:returnType,"inline.",'','')
              \ . "\<tab>" . a:signature . curly]
      else
        let lines += [  a:returnType . "\<tab>" . a:signature . curly ]
      endif
      if '' == curly
        let lines += [  '{'  ]
      endif
      let lines += [  a:instruction  ]
      let lines += [  '}'  ]
    else
      " normal! ==<<
      let lines += [  a:returnType . "\<tab>" . a:signature .";"  ]
    endif
    call s:InsertLines(lines)
  finally
    let &foldenable = old_foldenable
  endtry
endfunction

" Function: s:InsertAccessor {{{4
function! s:InsertAccessor(className, returnType, signature, instruction, comment)
  try 
    let old_foldenable = &foldenable
    set nofoldenable
    if exists('g:mu_template') && 
          \ (   !exists('g:mt_jump_to_first_markers') 
          \  || g:mt_jump_to_first_markers)
      " NB: g:mt_jump_to_first_markers is true by default
      let mt_jump = 1
      let g:mt_jump_to_first_markers = 0
    endif

    let implPlace = lh#dev#option#get('implPlace', 'cpp', 0)
    let in_place = implPlace == 0 
          \ || expand('%:e') =~? 'c\|cpp\|c++'
    if in_place " within the class definition /à la/ Java
      call s:WriteAccessor(a:returnType, a:signature, a:instruction, a:comment)
    else
      let returnType  = a:returnType
      let instruction = a:instruction
      " 1- Insert the prototype
      call s:WriteAccessor(a:returnType, a:signature, '', a:comment)
      let fn = expand("%")
      let l_line = line('.')
      " 2- Find the right place
      if     implPlace == 1 " Inline section of the right file {{{
        let returnType = "inline\n" . returnType
        call Cpp_ReachInlinePart(a:className)
        " }}}
      elseif implPlace == 2 " Within implementation file {{{
        silent AS cpp
        normal! G
        " }}}
      elseif implPlace == 3 " use the pimpl idiom {{{
        silent AS cpp
        normal! G
        if exists('*Marker_Txt') && 
              \ ( (exists('b:usemarks') && b:usemarks) || !exists('b:usemarks'))
          let instruction = Marker_Txt(';;')
        else
          let instruction = ';;'
        endif
        " does nothing !!!
        " }}}
      endif
      " 3- Insert the implementation
      let signature = a:className."::".a:signature
      call s:WriteAccessor(returnType, signature, instruction, a:comment)
      " 4- go back after the last prototype inserted
      call FindOrCreateBuffer(fn,1)
      exe ":".(l_line)
    endif
  finally
    let &foldenable = old_foldenable
    if exists('mt_jump')
      let g:mt_jump_to_first_markers = mt_jump
      unlet mt_jump
    endif
  endtry
endfunction
" Nb: the mt_jump stuff is required in order to not mess things up with
" automatically (by the mean of mu-template) built .cpp files.

function! s:Comment(attribute, accessor_type) "{{{4
  let template = lh#option#get('accessor_comment_'.a:accessor_type,
        \ s:k_accessor_comment_{a:accessor_type})
  return substitute(template, '%a',a:attribute,'g')
endfunction

" Function:	AddAttribute			{{{4
" Options:	g:getPrefix (default = "get_")
" 		g:setPrefix (default = "set_")
" 		g:refPrefix (default = "ref_")
function! Cpp_AddAttribute()
  :CheckOptions
  " Todo: factorize and move this elsewhere
  " GUI : request name and type  {{{
  echo "--------------------------------------------"
  echo "Adding an attribute to the current class ..."
  echo "--------------------------------------------"
  let type = input("Type of the new attribute : ")
  echo "\n"
  if strlen(type)==0 | call input("Aborting...") | return | endif
  let name = input("Name of the new attribute : ")
  echo "\n"
  if strlen(name)==0 | call input("Aborting...") | return | endif
  " }}}
  "
  " TODO: Place the cursor where the attribute must be defined

  " Insert the attribute itself
  let attrName = lh#dev#naming#member(name)
  let lines=[ s:Comment(name, 'attribute'),
        \ type . "\<tab>" . attrName . ';'
        \ ]
  call s:InsertLines(lines)

  " TODO: Place the cursor where accessors must be defined
  let l_line = line('.')
  let c_col  = col('.')
  let className = lh#cpp#AnalysisLib_Class#CurrentScope(l_line, 'any')

  " const correct type
  let ccType      = lh#dev#cpp#types#ConstCorrectType(type)

  " Insert the get accessor {{{
  let proxyType   = 0
  let choice = confirm('Do you want a get accessor ?', "&Yes\n&No\n&Proxy", 1) 
  if choice == 1
    let comment     = s:Comment(name, 'get')
    let signature   = lh#dev#naming#getter(name) . "()\<tab>const"
    let instruction = 'return ' . attrName . ';'
    call s:InsertAccessor(className, ccType, signature, instruction, comment)
  elseif choice == 3
    let proxyType = input( 'Proxy type                : ') | echo "\n"
    let comment     = s:Comment(name, 'proxy_get')
    let signature   = lh#dev#naming#getter(name) . "()\<tab>const"
    let instruction = 'return ' . proxyType.'('.attrName . ' /*,this*/);'
    call s:InsertAccessor(className, 'const '.proxyType, signature, instruction, comment)
  endif " }}}

  " Insert the set accessor {{{
  if confirm('Do you want a set accessor ?', "&Yes\n&No", 1) == 1
    let comment     = s:Comment(name, 'set')
    let signature   = lh#dev#naming#setter(name)
          \ . '('. ccType .' '. lh#dev#naming#param(name) .')'
    let instruction = attrName . ' = '.name.';'
    call s:InsertAccessor(className, 'void', signature, instruction, comment)
    if proxyType != ""
      let comment     = s:Comment(name, 'proxy_set')
      let signature   = lh#dev#naming#setter(name) . '('. proxyType .'& '. name .')'
      let instruction = attrName . ' = '.name.';'
      call s:InsertAccessor(className, 'void', signature, instruction, comment)
    endif
  endif " }}}

  " Insert the ref accessor {{{
  if confirm('Do you want a reference accessor ?', "&Yes\n&No", 1) == 1
    if proxyType == ""
      let comment     = s:Comment(name, 'ref')
      let signature   = lh#dev#naming#ref_getter(name) . "()\<tab>"
      let instruction = 'return ' . attrName . ';'
      call s:InsertAccessor(className, type.'&', signature, instruction, comment)
    else
      let comment     = s:Comment(name, 'proxy_ref')
      let signature   = lh#dev#naming#proxy_getter(name) . "()\<tab>"
      let instruction = 'return ' . proxyType.'('.attrName . ' /*,this*/);'
      call s:InsertAccessor(className, proxyType, signature, instruction, comment)
    endif
  endif " }}}

  " TODO: Go back to the class initial cursor's position
  " -> l_line, l_col...
  exe ":" . l_line
endfunction

" Functions }}}2
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
