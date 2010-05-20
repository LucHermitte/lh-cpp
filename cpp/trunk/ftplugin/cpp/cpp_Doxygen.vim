"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_Doxygen.vim                              {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	1.1.0
" Created:	22nd Nov 2005
" Last Update:	$Date$ (08th Feb 2008)
"------------------------------------------------------------------------
" Description:	
" 	Provides the command :DOX that expands a doxygened documentation for
" 	the current C|C++ function.
"
" 	:DOX tries to guess various things like:
" 	- the direction ([in], [out], [in,out]) of the parameters
" 	- ...
"
" 	It also comes with the following template-file:
" 	- a\%[uthor-doxygen] + CTRL-R_TAB
"
"
" Options:
" 	- [bg]:CppDox_CommentLeadingChar
" 	- [bg]:CppDox_TagLeadingChar
" 	- g:CppDox_author_tag
" 	- [bg]:CppDox_ingroup
" 	- [bg]:CppDox_brief
" 
"------------------------------------------------------------------------
" Installation:	See |lh-cpp-readme.txt|
" Dependencies:	Mu-template
" }}}1
"=============================================================================

if version < 700
  finish " Vim 7 required
endif

"=============================================================================
" Avoid buffer reinclusion {{{1
if exists('b:loaded_ftplug_cpp_Doxygen') && !exists('g:force_reload_cpp_Doxygen')
  finish
endif
let b:loaded_ftplug_cpp_Doxygen = 1
 
let s:cpo_save=&cpo
set cpo&vim
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1

" todo: arguments (with auto completion) for brief, ingroup, author, since, ...
" todo: align arguments and their descriptions
" todo: exceptions specifications
" todo: detect returned type

command! -buffer -nargs=0 DOX :call s:Doxygenize()
 
" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("s:loaded_cpp_Doxygen") 
      \ && !exists('g:force_reload_cpp_Doxygen')
  let &cpo=s:cpo_save
  finish 
endif
let s:loaded_cpp_Doxygen_vim = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1

" require Cpp_GetListOfParams and Cpp_GetFunctionPrototype

function! s:CommentLeadingChar()
  return lh#option#get('CppDox_CommentLeadingChar', '*', 'bg')
endfunction

function! s:TagLeadingChar()
  return lh#option#get('CppDox_TagLeadingChar', '@', 'bg')
  " alternative: \
endfunction

function! s:Tag(tag)
  return s:TagLeadingChar().a:tag
endfunction

function! CppDox_snippet(tagname, commentLeadingChar)
  let varType = type(g:CppDox_{a:tagname}_snippet)
  if varType == type([]) " List
    let sValue = join(g:CppDox_{a:tagname}_snippet, "\n".a:commentLeadingChar)
  else
    let sValue = g:CppDox_{a:tagname}_snippet
  endif
  if strlen(sValue) != 0
    let sValue = a:commentLeadingChar . sValue
  endif
  " echomsg a:tagname . " -> " . sValue
  return sValue
endfunction

" Function: CppDox_author()                           {{{2
let s:author_tag = lh#option#get('CppDox_author_tag', 'author', 'g')

function! CppDox_author()
  let s:author_tag = lh#option#get('CppDox_author_tag', 'author', 'g')
  let tag         = s:TagLeadingChar() . s:author_tag . ' '

  let author = lh#option#get('CppDox_author', '', 'bg')
  if author =~ '^g:.*'
    if exists(author) 
      return tag . {author}
      " return tag . {author} . Marker_Txt('')
    else
      return tag . Marker_Txt('author-name')
    endif
  elseif strlen(author) == 0
    return tag . Marker_Txt('author-name')
  else
    return tag . author
    " return tag . author . Marker_Txt('')
  endif
endfunction

" Function: s:ParameterDirection(type)               {{{2
function! s:ParameterDirection(type)
  " todo: enhance the heuristics.
  " Support for boost smart pointers, custom types, ...
  if     a:type =~ '\%(\<const\>\s*[&*]\=\|const_\%(reference\|iterator\)\)\s*$'
    return '[in]'
  elseif a:type =~ '\%([&*]\|reference\|pointer\|iterator\)\s*$'
    return '[' . Marker_Txt('in,') . 'out]'
  else
    return Marker_Txt('[in]')
  endif
endfunction

" Function: CppDox_set_brief_snippet(type)           {{{2
function! CppDox_set_brief_snippet()
  let brief = lh#option#get('CppDox_brief', 'short', 'bg')
  if     brief =~? '^y\%[es]$\|^a\%[lways]$\|1'
    let g:CppDox_brief_snippet = s:Tag('brief ').Marker_Txt('brief').'.'
  elseif brief =~? '^no$\|^n\%[ever]$\|0'
    let g:CppDox_brief_snippet = Marker_Txt('brief').'.'
  elseif brief =~? '^s\%[hort]$'
    let g:CppDox_brief_snippet = Marker_Txt('autobrief').'.'
  else " maybe
    let g:CppDox_brief_snippet = Marker_Txt(s:Tag('brief ')).'.'
  endif
endfunction
" Function: s:Doxygenize()                            {{{2
function! s:Doxygenize()
  " Obtain informations from the function at the current cursor position.
  let proto  = lh#cpp#AnalysisLib_Function#GetFunctionPrototype(line('.'), 0)
  let info   = lh#cpp#AnalysisLib_Function#AnalysePrototype(proto)
  let params = info.parameters
  let ret    = info.return

  " Build data to insert
  "
  " Parameters
  let g:CppDox_Params_snippet = []
  for param in params
    let sValue =
	  \  s:Tag("param")
	  \ . s:ParameterDirection(param[0])
	  \ . ' ' . param[1]
	  \ . '  ' . Marker_Txt('explanations') 
    call add (g:CppDox_Params_snippet, sValue)
  endfor

  " Ingroup
  let ingroup = lh#option#get('CppDox_ingroup', 0, 'bg')
  if     ingroup =~? '^y\%[es]$\|^a\%[lways]$\|1'
    let g:CppDox_ingroup_snippet = s:Tag('ingroup ').Marker_Txt('group')
  elseif ingroup =~? '^no$\|^n\%[ever]$\|0'
    let g:CppDox_ingroup_snippet = ''
  else " maybe
    let g:CppDox_ingroup_snippet = Marker_Txt(s:Tag('ingroup '))
  endif

  " Brief
  call CppDox_set_brief_snippet()

  if ret =~ 'void\|^$'
    let g:CppDox_return_snippet = ''
  else
    let g:CppDox_return_snippet	  = s:Tag('return ').Marker_Txt(ret) 
  endif

  " todo
  " empty => @throw None
  " list => n x @throw list
  " non-existant => markerthrow
  if !has_key(info, 'throw') || len(info.throw) == 0 
    let g:CppDox_exceptions_snippet = Marker_Txt(s:Tag('throw '))
  else
    let throws = info.throw
    let empty_marker = Marker_Txt('')
    if len(throws) == 1 && strlen(throws[0]) == 0 
      let g:CppDox_exceptions_snippet = s:Tag('throw ').'None'.empty_marker
    else
      call map(throws, '"'.s:Tag('throw ').'".v:val. empty_marker')
      let g:CppDox_exceptions_snippet = throws
    endif
  endif

  " goto begining of the function
  :put!=''
  " Load the template
  :MuTemplate cpp/doxygen-function

  " release parameters of the template-file
  unlet g:CppDox_Params_snippet
  unlet g:CppDox_return_snippet
  unlet g:CppDox_exceptions_snippet
  unlet g:CppDox_ingroup_snippet
  unlet g:CppDox_brief_snippet

endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
