" ========================================================================
" $Id$
" File:		ftplugin/cpp/cpp_InsertAccessors.vim                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" Last Change:	$Date$ (28th July 2003)
" Version:	1.1.0
"
"------------------------------------------------------------------------
" Description:	
" 	Defines a function to insert const-correct accessors and mutators.
"
" 	Used in cpp_BuildTemplates.vim
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	cpp_options.vim,
" 		cpp_FindContextClass.vim,
" 		cpp_options-commands.vim
" 		a.vim	(alternate files -> :AS())
" 		VIM 6.0 +
" Options:	cf. cpp_options.vim
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

if exists("g:loaded_cpp_InsertAccessors") | finish | endif
  let g:loaded_cpp_InsertAccessors = 1
  "
  "" line continuation used here ??
  let s:cpo_save = &cpo
  set cpo&vim

" ==========================================================================
" VIM Includes {{{
" ==========================================================================
" Dependencies {{{
function! s:CheckDeps(Symbol, File, path) " {{{
  if !exists(a:Symbol)
    exe "runtime ".a:path.a:File
    " runtime ftplugin/cpp/cpp_FindContextClass.vim
    if !exists(a:Symbol)
      if has('gui_running')
	call confirm(
	      \ '<cpp_InsertAccessors.vim> requires <'.a:File.'>',
	      \ '&Ok', '1', 'Error')
      else
	" echohl ErrorMsg
	echoerr '<cpp_InsertAccessors.vim> requires <'.a:File.'>'
	" echohl None
      endif
      return 0
    endif
  endif
  return 1
endfunction " }}}
if   
      \    !s:CheckDeps('*Cpp_SearchClassDefinition', 
      \			'cpp_FindContextClass.vim', 'ftplugin/cpp/')
      \ || !s:CheckDeps(':CheckOptions',
      \			'cpp_options-commands.vim', 'ftplugin/cpp/')
      \ || !s:CheckDeps('*Cpp_ReachInlinePart',
      \			'cpp_BuildTemplates.vim', 'ftplugin/cpp/')
  let &cpo=s:cpo_save
  finish
endif
" }}}
" }}}
" ==========================================================================
" ==========================================================================
" Insertion of accessors {{{
"
  ""so <sfile>:p:h/cpp_FindContextClass.vim

function! s:InsertComment(text) "{{{
  if "" != a:text
    silent put = a:text
    silent normal! ==<<
  endif
endfunction
" }}}
function! s:InsertLine(text) "{{{
  silent put = a:text
  silent normal! ==
endfunction
" }}}

" Function: s:WriteAccessor	{{{
function! s:WriteAccessor(returnType, signature, instruction, comment)
  let old_foldenable = &foldenable
  set nofoldenable
  call s:InsertComment( a:comment)
  if '' != a:instruction
    let curly = (exists('g:c_nl_before_curlyB') && g:c_nl_before_curlyB)
	  \ ? "" : "\<tab>{"
    if a:returnType =~ "^inline"
      call s:InsertLine('inline')
      call s:InsertLine( substitute(a:returnType,"inline.",'','')
	    \ . "\<tab>" . a:signature . curly)
    else
      call s:InsertLine( a:returnType . "\<tab>" . a:signature . curly)
    endif
    if '' == curly
      call s:InsertLine( '{' )
    endif
    call s:InsertLine( a:instruction )
    call s:InsertLine( '}' )
  else
    " normal! ==<<
    call s:InsertLine( a:returnType . "\<tab>" . a:signature .";" )
  endif
  let &foldenable = old_foldenable
endfunction
" }}}
" Function: s:InsertAccessor {{{
function! s:InsertAccessor(className, returnType, signature, instruction, comment)
  let old_foldenable = &foldenable
  set nofoldenable
  if g:implPlace == 0 " within the class definition /à la/ Java
    call s:WriteAccessor(a:returnType, a:signature, a:instruction, a:comment)
  else
    let returnType  = a:returnType
    let instruction = a:instruction
    " 1- Insert the prototype
    call s:WriteAccessor(a:returnType, a:signature, '', a:comment)
    let fn = expand("%")
    let l_line = line('.')
    " 2- Find the right place
      if exists('g:mu_template') && 
	    \ (   !exists('g:mt_jump_to_first_markers') 
	    \  || g:mt_jump_to_first_markers)
	" NB: g:mt_jump_to_first_markers is true by default
	let mt_jump = 1
	let g:mt_jump_to_first_markers = 0
      endif
    if     g:implPlace == 1 " Inline section of the right file {{{
      let returnType = "inline\n" . returnType
      call Cpp_ReachInlinePart(a:className)
      " }}}
    elseif g:implPlace == 2 " Within implementation file {{{
      silent AS cpp
      normal! G
      " }}}
    elseif g:implPlace == 3 " use the pimpl idiom {{{
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
    if exists('mt_jump')
      let g:mt_jump_to_first_markers = mt_jump
      unlet mt_jump
    endif
  endif
  let &foldenable = old_foldenable
endfunction
" Nb: the mt_jump stuff is required in order to not mess things up with
" automatically (by the mean of mu-template) built .cpp files.
" }}}
"
function! s:Comment(attribute, accessor_type) "{{{
  return substitute(g:accessor_comment_{a:accessor_type}, '%a',a:attribute,'g')
endfunction
" }}}

" Function:	AddAttribute			{{{
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
  let attrName = g:dataPrefix.name.g:dataSuffix
  call s:InsertComment( s:Comment(name, 'attribute') )
  call s:InsertLine(type . "\<tab>" . attrName . ';')

  " TODO: Place the cursor where accessors must be defined
  let l_line = line('.')
  let c_col  = col('.')
  let className = Cpp_SearchClassDefinition(l_line)

  " Change the capitalization of the first letter {{{
  " ... of the attribute for the accessors names. -> getAttribute()
  if g:accessorCap == -1
    let accessName = tolower(name[0]).strpart(name,1)
  elseif g:accessorCap == 0
    let accessName = name
  else
    let accessName = toupper(name[0]).strpart(name,1)
  endif
  " }}}

  let ccType      = lh#cpp#types#ConstCorrectType(type)
  " Insert the get accessor {{{
  let proxyType   = 0
  let choice = confirm('Do you want a get accessor ?', "&Yes\n&No\n&Proxy", 1) 
  if choice == 1
    let comment     = s:Comment(name, 'get')
    let signature   = g:getPrefix . accessName .  "()\<tab>const"
    let instruction = 'return ' . attrName . ';'
    call s:InsertAccessor(className, ccType, signature, instruction, comment)
  elseif choice == 3
    let proxyType = input( 'Proxy type                : ') | echo "\n"
    let comment     = s:Comment(name, 'proxy_get')
    let signature   = g:getPrefix . accessName .  "()\<tab>const"
    let instruction = 'return ' . proxyType.'('.attrName . ' /*,this*/);'
    call s:InsertAccessor(className, 'const '.proxyType, signature, instruction, comment)
  endif " }}}

  " Insert the set accessor {{{
  if confirm('Do you want a set accessor ?', "&Yes\n&No", 1) == 1
    let comment     = s:Comment(name, 'set')
    let signature   = g:setPrefix.accessName . '('. ccType .' '. name .')'
    let instruction = attrName . ' = '.name.';'
    call s:InsertAccessor(className, 'void', signature, instruction, comment)
    if proxyType != ""
      let comment     = s:Comment(name, 'proxy_set')
      let signature   = g:setPrefix.accessName . '('. proxyType .'& '. name .')'
      let instruction = attrName . ' = '.name.';'
      call s:InsertAccessor(className, 'void', signature, instruction, comment)
    endif
  endif " }}}

  " Insert the ref accessor {{{
  if confirm('Do you want a reference accessor ?', "&Yes\n&No", 1) == 1
    if proxyType == ""
      let comment     = s:Comment(name, 'ref')
      let signature   = g:refPrefix . accessName .  "()\<tab>"
      let instruction = 'return ' . attrName . ';'
      call s:InsertAccessor(className, type.'&', signature, instruction, comment)
    else
      let comment     = s:Comment(name, 'proxy_ref')
      let signature   = g:getPrefix . accessName .  "()\<tab>"
      let instruction = 'return ' . proxyType.'('.attrName . ' /*,this*/);'
      call s:InsertAccessor(className, proxyType, signature, instruction, comment)
    endif
  endif " }}}

  " TODO: Go back to the class initial cursor's position
  " -> l_line, l_col...
  exe ":" . l_line
endfunction
" }}}
" }}}
  let &cpo = s:cpo_save
" ========================================================================
" vim60: set fdm=marker:
