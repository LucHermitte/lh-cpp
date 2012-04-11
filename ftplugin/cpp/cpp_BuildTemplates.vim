" ========================================================================
" $Id$
" File:		ftplugin/cpp/cpp_BuildTemplates.vim                   {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Last Update:	$Date$ (28th Jul 2003)
"------------------------------------------------------------------------
" Description:	«description»
"
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	a.vim (Alternate files)
" TODO:	
" * Correct the ftplugin to be VIM 6 fully compliant
" * Delete what's redundant with µTemplate's templates
" }}}1
" ========================================================================

" ========================================================================
" Buffer local definitions {{{1
" ========================================================================
if exists("b:loaded_cpp_BuildTemplates_local_settings") | finish | endif
let b:loaded_cpp_BuildTemplates_local_settings = 1
  let s:cpo_save = &cpo
  set cpo&vim

" ------------------------------------------------------------------------
" Commands {{{2
" ------------------------------------------------------------------------
" Command:	:HEADER
" Map shortcut:	;HE
" Purpose:	Insert the template for a header file (.h) plus a class
" Parameter: 	<1> == Name of the main class of the file
" Note:		Use the same function than :CLASS for inserting the class
" 		template.
  command! -buffer -nargs=1 HEADER :call <sid>Cpp_newHeaderFile(<q-args>)
  nnoremap <buffer> ;HE :HEADER<space>
"
" Command:	:CLASS
" Map shortcut:	;CL
" Purpose:	Insert the template for a class
" Parameter: 	<1> == Name of the class
  command! -buffer -nargs=1 CLASS :call <sid>Cpp_newClass(<q-args>)
  nnoremap <buffer> ;CL :CLASS<space>
"
" Command:	:BLINE
" Map shortcut:	;BL
" Purpose:	Insert a 3 lines separator
" Parameter:	<1> == Title of the separation
  command! -buffer -nargs=1 BLINE :call <sid>Cpp_bigLine(<q-args>)
  nnoremap <buffer> ;BL :BLINE<space>
"
" Command:	:MGROUP
" Map shortcut:	;MGR
" Purpose:	Insert a group plus a separator line
" Parameter:	<1> == Name of the group
  command! -buffer -nargs=1 MGROUP :call <sid>Cpp_megagroup(<q-args>)
  nnoremap <buffer> ;MGR :MGROUP<space>
"
" Command:	:GROUP
" Map shortcut:	;GR
" Purpose:	Insert a group
" Parameter:	<1> == Name of the group
  command! -buffer -nargs=1 GROUP :call <sid>Cpp_group(<q-args>)
  nnoremap <buffer> ;GR :GROUP<space>
"
" Command:	:ADDATTRIBUTE
" Map shortcut:	;AA
" Purpose:	Insert an attribute plus its accessors to the current class
  command! -buffer -nargs=0 ADDATTRIBUTE :call Cpp_AddAttribute()
  nnoremap <buffer> ;AA :ADDATTRIBUTE<cr>
"
" Command:	:REACHINLINE
" Map shortcut:	;RI
" Purpose:	Reach the location of inlines for the specified class
  command! -buffer -nargs=1 REACHINLINE :call Cpp_ReachInlinePart(<q-args>)
  nnoremap <buffer> ;RI :REACHINLINE<space>
" ==========================================================================
" Mappings {{{2
" ;GR <foo>  inserts /**@name <foo>
"                     */
"                    //@{
"                    //@}
" suppose so=coqlr
inoremap <buffer> //@{ <c-R>=MapNoContext('//@{',
      \ '//@{\<cr\>@}')<cr>
"      \ '//@{\<cr\>@}\<esc\>O\<bs\>\<bs\>')<cr>


" ========================================================================
" General Definitions {{{1
" ========================================================================
if exists("g:loaded_cpp_BuildTemplates_vim") 
  let &cpo = s:cpo_save
  finish 
endif
let g:loaded_cpp_BuildTemplates_vim = 1

" Constants {{{2
let s:header_includes_text = 'Includes'
let s:header_inlines_text = 'Inlines'
let s:header_inlines_type = '='
let s:header_inlining_text = 'Inlinings for '
let s:header_inlining_type = '='

let s:EqLine= '/*===========================================================================*/'
let s:MnLine= '/*---------------------------------------------------------------------------*/'

" Functions {{{2
  inoremap /*1 0<c-d>/*<esc>75a=<esc>a*/
function! s:Cpp_group(name) " {{{3
  " TODO: use indent()
  silent put = '    /**'. lh#dox#tag('name') 
  silent put = '     */'
  silent put = '    //@{'
  silent put = '    //@}'
endfunction

function! s:Cpp_bigLine(title) " {{{3
  silent put = s:EqLine
  let pos = (79-lh#encoding#strlen(a:title)-4)/2
  silent put = substitute(s:EqLine, 
	\ '\(.\{'.pos.'}\).\{'.(lh#encoding#strlen(a:title)+4).'}\(.*\)$', 
	\ '\1[ '.a:title.' ]\2', '')
  silent put = s:EqLine
endfunction

function! s:Cpp_littleLine(title) " {{{3
  let pos = (79-lh#encoding#strlen(a:title)-4)/2
  silent put = substitute(s:MnLine, 
	\ '\(.\{'.pos.'}\).\{'.(lh#encoding#strlen(a:title)+4).'}\(.*\)$', 
	\ '\1[ '.a:title.' ]\2', '')
endfunction

function! s:Cpp_megagroup(name) " {{{3
  call s:Cpp_littleLine(a:name)
  call s:Cpp_group(a:name)
endfunction

function! s:Cpp_emptyLine(nb) " {{{3
  let fo = &fo | set fo-=o
  exe "normal! ".a:nb."o\<esc>\<esc>"
  let &fo = fo
endfunction

function! s:Cpp_addGroup(emptyLine, name, access) " {{{3
  if a:emptyLine != 0
    call s:Cpp_emptyLine( a:emptyLine )
  endif
  call s:Cpp_megagroup( a:name )
  let fo = &fo | set fo-=o
  exe "normal! O".a:access."\<esc>"
  let &fo = fo
endfunction

function! s:Cpp_addMethod(name, sig) " {{{3
  silent put = '    /* '.a:name.' */'
  silent put = '        '.a:sig
endfunction

" ==========================================================================
" Search for parts {{{3
" ==========================================================================
" Function:	Cpp_search4line 
" Returns:	line of the found pattern
function! s:Cpp_search4line(title,type)
  " let v:errmsg = ''
  let str = '\/\*' . a:type . '*\[\s*' . a:title . '\s*\]' . a:type . '*\*\/'
  return search(str)
  " exe '/'.str
  ""let str = '/\*' . a:type . '*\[\s*' . a:title . '\s*\]' . a:type . '*\*/'
  ""exe '?'.str
  " return strlen(v:errmsg) != 0
endfunction
" ==========================================================================
" Add classes {{{3
" ==========================================================================
function! s:Cpp_newClass(name)
  " if exists('b:usemarks') && b:usemarks
    " let b:usemarks = 0
    " let recall_usemarks = 1
  " else
    " let recall_usemarks = 0
  " endif
  " class
  let old_foldenable = &foldenable
  set nofoldenable
  call s:Cpp_bigLine( "Class ".a:name )
  silent put = 'class ' . a:name
  silent put = '{'

  " contructions , added after every other group because of reindentation
  call s:Cpp_addGroup(0, "Construction", "public:")
  call s:Cpp_addMethod("Argument-less constructor", a:name."();")
  call s:Cpp_addMethod("Copy constructor", a:name."(const ".a:name." & rhs);")
  call s:Cpp_addMethod("Copy operator", a:name."& operator=(const ".a:name." & rhs);")
  call s:Cpp_addMethod("Destructor", "virtual ~".a:name."();")

  " public methods
  call search('}')
  call s:Cpp_addGroup(1, "Public methods", "public:")
  
  " internal methods
  call search('}')
  call s:Cpp_addGroup(1, "Internal methods", "protected:")
  
  " Data
  call search('}')
  call s:Cpp_addGroup(1, "Data", "private:")
  
  " End of class
  call search('}')
  call s:Cpp_emptyLine( 1 )
  call s:Cpp_littleLine( "End of class" )
  silent put = '};'
  " if recall_usemarks == 1 | let b:usemarks = 1 | endif
  let &foldenable = old_foldenable
endfunction
" ==========================================================================
function! s:Cpp_newHeaderFile(name) " {{{3
  " reinclusion
  call s:Cpp_bigLine( "Avoid re-inclusion")
  silent put = '#ifndef __'.toupper(a:name).'_H__'
  silent put = '#define __'.toupper(a:name).'_H__'
  call s:Cpp_emptyLine( 2 )

  " Includes
  call s:Cpp_bigLine( s:header_includes_text )
  if exists('*Marker_Txt') 
    silent put = '// ' . Marker_Txt('Includes') 
  endif
  call s:Cpp_emptyLine( 2 )

  " Class
  call s:Cpp_newClass(a:name)

  " reinclusion
  normal! G
  call s:Cpp_emptyLine( 2 )
  call s:Cpp_bigLine( "Avoid re-inclusion")
  silent $ put = '#endif'
endfunction
" ==========================================================================
" Inlines {{{3
" ==========================================================================
" Function: Cpp_fileType(name) {{{4
" Returns:	A number indicating the kind of C++ file involved
" 		0 : header file ; 1 : inlines file ; 2 : other (.cpp & co)
function! s:Cpp_fileType(name)
  if a:name =~'\.hh\=$'                               | return 0
  elseif a:name =~ Cpp_FileExtension4Inlines() . '$'  | return 1
  else                                                | return 2
  endif
endfunction

" Function: Cpp_fileExtension(type) {{{4
function! s:Cpp_fileExtension(type)
  if a:type == 0      | return 'h'
  elseif a:type == 1  | let ret = Cpp_FileExtension4Inlines()
  else                | let ret = Cpp_FileExtension4Implementation()
  endif
  return strpart(ret,1,strlen(ret)-1)
endfunction

" Function: Cpp_fileName(name0,type) {{{4
" Purpose:	Substitute the file extension regarding the final type
" 		expected.
" Returns:	A filename built on the basename from <name0> and of type
" 		<type> (cf. Cpp_fileType for the value of <type>)
function! s:Cpp_fileName(name0,type)
  return expand(a:name0.":r") . '.' .s:Cpp_fileExtension(a:type)
endfunction

" Function: Cpp_TestInlineFile(filename,type,class) {{{4
" Purpose:	Looks for inlining section of the class <class> in the file
" 		of type <type>
" Returns:	The line of the section / -1 if no found		
function! s:Cpp_TestInlineFile(filename,type,class)
  if exists('g:mu_template') && 
	\ (!exists('g:mt_jump_to_first_markers') || g:mt_jump_to_first_markers)
    " NB: g:mt_jump_to_first_markers is true by default
    let mt = g:mt_jump_to_first_markers
    let g:mt_jump_to_first_markers = 0
  endif
  let fn = s:Cpp_fileName(a:filename,a:type)
  ""if filereadable(fn) || y a buffer du meme nom...
    call FindOrCreateBuffer(fn,1)
  if exists('mt')
    let g:mt_jump_to_first_markers = mt
  endif
    if s:Cpp_search4line(s:header_inlining_text.a:class,s:header_inlining_type)
      return line('.')
    else
      bdelete
    endif
  ""endif
  return -1
endfunction

function! s:Cpp_addInlinesInHeader(name)	" Internal use {{{4
  normal! G
  call s:Cpp_emptyLine( 3 )
  call s:Cpp_bigLine( "Inlines")
  call s:Cpp_littleLine( "Check whether inlines required" )
  " exe "normal! i#ifdef __".a:name."_INL__\<esc>viwU"
  silent put = '#ifdef __'.toupper(a:name).'_INL__'
  call s:Cpp_emptyLine( 3 )

  call s:Cpp_littleLine( s:header_includes_text )

  " reinclusion
  call s:Cpp_emptyLine( 2 )
  call s:Cpp_bigLine( "End of Inlinings")
  silent put = '#endif          // Check if asked : __'.toupper(a:name).'_INL__'
  exe "normal! 4\<up>"
endfunction

function! s:Cpp_newInlineFile(name)	" Internal use {{{4
  normal! G
  call s:Cpp_bigLine( "Inlines")
  call s:Cpp_littleLine( "Avoid re-inclusion")
  silent put = '#ifndef __'.toupper(a:name).'_AvR_INL__'
  silent put = '#define __'.toupper(a:name).'_AvR_INL__'
  call s:Cpp_emptyLine( 2 )
  call s:Cpp_bigLine( s:header_includes_text )
  silent put = '#include \"'.a:name.'.h\"'
  call s:Cpp_emptyLine( 2 )

  call s:Cpp_littleLine( "Avoid re-inclusion")
  silent put ='#endif          //Avoid re-inclusion : __'.toupper(a:name).'_AvR_INL__'
  exe "normal! 2\<up>"
endfunction

" Function: ReachInlinesZone(type) {{{4
" Purpose:	Reach the inlines zone of a file, if the file does not
" 		exist, create it ; if the zone does not exist, create it.
function! s:ReachInlinesZone(type)
  if s:Cpp_search4line(s:header_inlines_text, s:header_inlines_type)
    call s:Cpp_search4line(s:header_includes_text, '[-=]')
    exe "normal! 2\<down>"
    return
  else
    if exists('g:mu_template') && 
	  \(!exists('g:mt_jump_to_first_markers') || g:mt_jump_to_first_markers)
      " NB: g:mt_jump_to_first_markers is true by default
      let mt = g:mt_jump_to_first_markers
      let g:mt_jump_to_first_markers = 0
    endif
    " !!! expand("%:r:t") does not work. "%:t:r" does.
    if a:type == 0     | call s:Cpp_addInlinesInHeader(expand("%:t:r"))
    elseif a:type == 1 | call s:Cpp_newInlineFile(expand("%:t:r"))
    endif
    if exists('mt')
      let g:mt_jump_to_first_markers = mt
    endif
  endif
endfunction

function! s:WriteInlinePart(name)	" Internal use {{{4
  " Class
  call s:Cpp_emptyLine( 1 )
  if s:header_inlining_type == '='
    call s:Cpp_bigLine( s:header_inlining_text. a:name)
  else
    call s:Cpp_littleLine( s:header_inlining_text. a:name)
  endif
  call s:Cpp_emptyLine( 1 )
endfunction

" =========================================================================
" Function: AddInlinePart(class,type)	{{{4
" Purpose:	Main function for accessing the inline zone of a class
function! s:AddInlinePart(class,type)	
  call s:ReachInlinesZone(a:type)
  call s:WriteInlinePart(a:class)
endfunction

function! s:TabSet(name,i,value) "{{{4
  exe 'let beg = strpart('.a:name.',0,'.a:i.')'
  let b = a:i+1
  let e = strlen(a:name)
  exe 'let end = strpart('.a:name.',b,e)'
  exe "let " . a:name . "= beg . a:value . end "
endfunction

" Function: Cpp_ReachInlinePart(class)		<external use> {{{4
" Purpose:	Reach the inlining part for the specifed class.
" 		Use the different options and already pre-existant
" 		structures.
function! Cpp_ReachInlinePart(class)
  " 1- look whether the part already exists
  let g:lookedin = 'nnn'
  " a- current file
  let i = s:Cpp_fileType(expand("%"))
  call s:TabSet('g:lookedin',i,'y')
  if s:Cpp_search4line(s:header_inlining_text.a:class, s:header_inlining_type)
    exe "normal! 2\<down>"
    return
  endif
  " b- prefered file (regarding options) (.inl / .h)
  let i = Cpp_fileTypeRegardingOption()
  if g:lookedin[i] == 'n'
    if s:Cpp_TestInlineFile("%", i, a:class) != -1
      exe "normal! 2\<down>"
      return
    endif
  endif
  " c- last possible location (.h / .inl), but never .cpp
  let i = 1 - i
  if g:lookedin[i] == 'n'
    if s:Cpp_TestInlineFile("%", i, a:class) != -1
      exe "normal! 2\<down>"
      return
    endif
  endif
"---
"   2- Othewise, build/add the part in the correct file
  exe ':silent AS ' . s:Cpp_fileExtension(1-i)
  " :CheckOptions
  call s:AddInlinePart(a:class, 1-i)
endfunction
" }}}1
" =========================================================================
  let &cpo = s:cpo_save
" =========================================================================
" vim60: set fdm=marker:
