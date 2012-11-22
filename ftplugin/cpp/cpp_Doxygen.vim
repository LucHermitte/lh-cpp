"=============================================================================
" $Id$
" File:		ftplugin/cpp/cpp_Doxygen.vim                              {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	2.0.0b1
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
" 	- [bg]:[&ft_]dox_CommentLeadingChar
" 	- [bg]:[&ft_]dox_TagLeadingChar
" 	- [bg]:[&ft_]dox_author_tag
" 	- [bg]:[&ft_]dox_ingroup
" 	- [bg]:[&ft_]dox_brief
" 	- [bg]:[&ft_]dox_throw
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

" Function: s:ParameterDirection(type)               {{{2
function! s:ParameterDirection(type)
  " todo: enhance the heuristics.
  " First strip any namespace/scope stuff

  " Support for boost smart pointers, custom types, ...
  if     a:type =~ '\%(\<const\>\s*[&*]\=\|const_\%(reference\|iterator\)\|&&\|\%(unique\|auto\)_ptr\)\s*$'
        \ . '\|^\s*\(\<const\>\)'
    return '[in]'
  elseif a:type =~ '\%([&*]\|reference\|pointer\|iterator\|_ptr\)\s*$'
    return '[' . Marker_Txt('in,') . 'out]'
  elseif lh#dev#cpp#types#IsBaseType(a:type, 0)
    return '[in]'
  else
    return Marker_Txt('[in]')
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
  " Parameters & preconditions
  let g:CppDox_Params_snippet = []
  let g:CppDox_preconditions_snippet = []
  for param in params
    " @param
    let sValue =
          \  lh#dox#tag("param")
          \ . s:ParameterDirection(param.type)
          \ . ' ' . param.name
          \ . '  ' . Marker_Txt((param.name).'-explanations') 
    call add (g:CppDox_Params_snippet, sValue)
    " pointer ? -> default non null precondition
    " todo: add an option if we don't want that by default (or even better, use
    " clang to check whether an assert is being used for that purpose...)
    if lh#dev#cpp#types#IsPointer(param.type)
      let sValue =
            \  lh#dox#tag("pre")
            \ . ' <tt>'.(param.name).' != NULL</tt>'
            \ . Marker_Txt() 
      call add(g:CppDox_preconditions_snippet, sValue)
    endif
  endfor

  " Ingroup
  let g:CppDox_ingroup_snippet = lh#dox#ingroup()

  " Brief
  let g:CppDox_brief_snippet = lh#dox#brief('')

  if ret =~ 'void\|^$'
    let g:CppDox_return_snippet = ''
  else
    let g:CppDox_return_snippet	  = lh#dox#tag('return ').Marker_Txt(ret) 
  endif

  " todo
  " empty => @throw None
  " list => n x @throw list
  " non-existant => markerthrow
  if !has_key(info, 'throw') || len(info.throw) == 0 
    let g:CppDox_exceptions_snippet = lh#dox#throw()
  else
    let throws = info.throw
    let empty_marker = Marker_Txt('')
    if len(throws) == 1 && strlen(throws[0]) == 0 
      let g:CppDox_exceptions_snippet = lh#dox#throw('None').empty_marker
    else
      call map(throws, 'lh#dox#throw(v:val). empty_marker')
      let g:CppDox_exceptions_snippet = throws
    endif
  endif

  " goto begining of the function
  :put!=''
  " Load the template
  :MuTemplate dox/function

  " release parameters of the template-file
  unlet g:CppDox_Params_snippet
  unlet g:CppDox_preconditions_snippet
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
