"=============================================================================
" File:		ftplugin/c/c_Doxygen.vim                                  {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
" 		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.1.2
let s:k_version = 212
" Created:	22nd Nov 2005
" Last Update:	26th Oct 2015
"------------------------------------------------------------------------
" Description:
" 	Provides the command :DOX that expands a doxygened documentation for
" 	the current C|C++ function.
"
" 	:DOX tries to guess various things like:
" 	- the direction ([in], [out], [in,out]) of the parameters
" 	- pointers that should not be null
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
if exists('b:loaded_ftplug_c_Doxygen') && !exists('g:force_reload_c_Doxygen')
  finish
endif
let b:loaded_ftplug_c_Doxygen = s:k_version

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
if exists("s:loaded_c_Doxygen")
      \ && !exists('g:force_reload_c_Doxygen')
  let &cpo=s:cpo_save
  finish
endif
let s:loaded_c_Doxygen_vim = 1
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

" Function: s:Doxygenize()                            {{{2
function! s:Doxygenize() abort
  let cleanup = lh#on#exit()
        \.restore('g:CppDox_Params_snippet')
        \.restore('g:CppDox_preconditions_snippet')
        \.restore('g:CppDox_return_snippet')
        \.restore('g:CppDox_exceptions_snippet')
        \.restore('g:CppDox_ingroup_snippet')
        \.restore('g:CppDox_brief_snippet')
  try
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
            \ . lh#dox#_parameter_direction(param.type)
            \ . ' ' . param.name
            \ . '  ' . lh#marker#txt((param.name).'-explanations')
      call add (g:CppDox_Params_snippet, sValue)
      " pointer ? -> default non null precondition
      " todo: add an option if we don't want that by default (or even better, use
      " clang to check whether an assert is being used for that purpose...)
      if lh#dev#cpp#types#IsPointer(param.type)
        let sValue =
              \  lh#dox#tag("pre")
              \ . ' <tt>'.(param.name).' != NULL</tt>'
              \ . lh#marker#txt()
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
      let g:CppDox_return_snippet	  = lh#dox#tag('return ').lh#marker#txt(ret)
    endif

    " todo
    " empty => @throw None
    " list => n x @throw list
    " non-existant => markerthrow
    " noexcept
    if !has_key(info, 'throw') || len(info.throw) == 0
      let g:CppDox_exceptions_snippet = lh#dox#throw()
    else
      let throws = info.throw
      let empty_marker = lh#marker#txt('')
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

  finally
    call cleanup.finalize()
  endtry
endfunction

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
