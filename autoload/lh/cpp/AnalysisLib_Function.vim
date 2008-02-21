"=============================================================================
" $Id$
" File:		autoload/lh/cpp/AnalysisLib_Function.vim                                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	1.0.1
" Created:	05th Oct 2006
" Last Update:	$Date$ (13th Feb 2008)
"------------------------------------------------------------------------
" Description:	
" 	This plugin defines VimL functions specialized in the analysis of C++
" 	code.
" 	It can be seen as a library plugin.
"
" Functions Defined:
" 	Scope: lh#cpp#AnalysisLib_Function#
" 
" 	GetFunctionPrototype(lineno, onlyDeclaration)
" 		@param lineno		Number of the line where the prototype is fetched
" 		@param onlyDeclaration	Restrict to function declarations (1), or
" 				       definition are accepted (0)
" 		@return The exact prototype found at the given line
"
" 	GetListOfParams(prototype)
" 		@param prototype	Prototype to analyse
" 		@return a list of [ {type}, {name}, {default value} ], one
" 			for each parameter specified in the prototype
"
" 	AnalysePrototype(prototype)
" 		@param prototype	Prototype to analyse
" 		@return a |dictionary| made of the following fields:
"			- qualifier: "" / "virtual" / "static" / "explicit"
"			- return: type of the value returned by the function
"			- name: list of the scopes + the name of the function
"			- parameters: @see GetListOfParams
"			- const: 0/1 whether the function is a const-member "			function
"			- throw: list of exception specified in the signature
" 
"------------------------------------------------------------------------
" Installation:	
" 	Drop it into: {rtp}/autoload
" 	Requirements: Vim7
" History:	
"	v1.0.1:
"	(*) Remembers the parameter is on a new line
"	v1.0.0: First version
"		Code extracted from cpp_GotoFunctionImpl
" TODO:		
" 	Support template, function types, friends
" }}}1
"=============================================================================
if version < 700 | finish | endif

"=============================================================================
"=============================================================================
" Avoid global reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists("g:loaded_cpp_CodeAnalysisLib") 
      \ && !exists('g:force_reload_cpp_CodeAnalysisLib')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_cpp_CodeAnalysisLib_vim = 1
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Functions {{{1
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#GetFunctionPrototype " {{{2
" Todo: 
" * Retrieve the type even when it is not on the same line as the function
"   identifier.
" * Retrieve the const modifier even when it is not on the same line as the
"   ')'.
function! s:GetFunctionPrototype(lineNo, onlyDeclaration)
  let endPattern = a:onlyDeclaration ? ';' : '[;{]'
  exe a:lineNo
  " 0- Goto end of current line of prototype (stop at the first found)
  normal! 0
  call search( ')\|\n')
  " 1- Goto start of current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;.*$\ze', 'bW')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'bW')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^{};]*'.endPattern, 'bW')
  let l0 = line('.')
  " 2- Goto the "end" of the current prototype
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')', 'W')
  " let pos = searchpair('\<\i\+\>\%(\n\|\s\)*(', '', ')\%(\n\|[^;]\)*;\zs','W')
  let pos = searchpair('\<\i\+\>\_s*(', '', ')\_[^{};]*'.endPattern.'\zs', 'W')
  let l1 = line('.')
  " Abort if nothing found
  if ((0==pos) || (l0>a:lineNo)) | return '' | endif
  " 3- Build the prototype string
  let proto = getline(l0)
  while l0 < l1
    let l0 = l0 + 1
    " Add the line, and trim any comments ending the line
    let proto = proto . "\n" .
	  \ substitute(getline(l0), '\s*//.*$\|\s*/\*.\{-}\*/\s*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$', '', 'g')
	  " \ substitute(getline(l0), '//.*$\|/\*.\{-}\*/', '', 'g')
  endwhile
  " 4- and return it.
  exe a:lineNo
  return proto
endfunction

function! lh#cpp#AnalysisLib_Function#GetFunctionPrototype(lineno, onlyDeclaration)
  return s:GetFunctionPrototype(a:lineno, a:onlyDeclaration)
endfunction
" }}}2

"------------------------------------------------------------------------
" Function: s:SplitTypeParam(typed_param) {{{2
" @return 4-uple -> [parameter-type, parameter-name, default-value, new-line-before]
" todo: support pointers to functions and arrays
" todo: 'int', 'unsigned int', 'char const*'
function! s:SplitTypeParam(typed_param)
  " Strip spaces
  let typed_param = substitute(a:typed_param, '\_s\+', ' ', 'g')
  " Extract default value
  let default = matchstr(typed_param, '^.\{-}\s*=\s*\zs.*\ze$')
  let typed_param = substitute(typed_param, '\s*=\s*'.escape(default,'\*'), '', '')
  " Type
  let t = matchstr(typed_param, '^\s*\zs.*\%(\ze\s\+\|[&*]\ze\s*\)\S\+')
  " Parameter
  let p = matchstr(typed_param, '^.*\%(\s\|[&*]\)\s*\zs\S\+')
  " New line before the parameter
  let nl = match(a:typed_param, "^\\s*[\n\r]") >= 0
  " Result
  return [t, p, default, nl]
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#GetListOfParams(prototype) {{{2
" todo: beware of exception specifications
" todo: check about of functions types ; to be done with templates... ?
function! lh#cpp#AnalysisLib_Function#GetListOfParams(prototype)
  " 1- Strip comments and parenthesis
  let prototype  = a:prototype
  let prototype  = substitute(prototype, '//.\{-}\n', '', 'g')
  let prototype  = substitute(prototype, '/\*\_.\{-}\*/', '', 'g')
  let parameters = matchstr  (prototype, '(\zs.*\ze)')

  " 2- convert the string into a list, the separation being done on commas
  let params = split(parameters, '\s*,\s*')

  " 3- merge the template parameters.
  let res_params = []
  let idx = 0
  let to_append = ''
  while idx < len(params) " for each element in the first list
    " string to append to the result list
    let to_append = to_append . (strlen(to_append)?',':'') . params[idx]
    " Reduce templates and function types ; take care of the recursive grammar
    let tpl = substitute(to_append, '[^<>()]\+', '', 'g')
    while strlen(tpl)
      let tpl2 = substitute(tpl, '<>\|()', '', 'g')
      if tpl == tpl2 | break | endif
      let tpl = tpl2
    endwhile
    if !strlen(tpl) " a complete parameter has been read
      " => append it to the result list 
      let res_params += [ s:SplitTypeParam(to_append) ]
      let to_append = ''
    endif
    let idx = idx + 1 " next
  endwhile
  return res_params
endfunction
" }}}2

" Function: lh#cpp#AnalysisLib_Function#AnalysePrototype(prototype) {{{2
" @return: {qualifier, return-type, function-name, parameters, throw-spec, const}
" @todo support friends.
" @todo support function types
" @todo support templates
" Constants {{{3
let s:re_qualifiers      = '\<\%(static\|explicit\|virtual\)\>'

let s:re_qualified_name1 = '\%(::\s*\)\=\<\I\i*\>'
let s:re_qualified_name2 = '\s*::\s*\<\I\i*\>'
let s:re_qualified_name  = s:re_qualified_name1.'\%('.s:re_qualified_name2.'\)*'

let s:re_operators       = '\<operator\%([=~%+-\*/^&|]\|[]\|()\|&&\|||\|->\|<<\|>>\| \)'
"   What looks like to a "space" operator is actually used in next regex to
"   match convertion operators
let s:re_qualified_oper  = '\%('.s:re_qualified_name . '\s*::\s*\)\=' . s:re_operators . '.\{-}\ze('

let s:re_const_member_fn = ')\s*\zs\<const\>'
let s:re_throw_spec      = ')\s*\%(\<const\>\s\+\)\=\<throw\>(\(\zs.*\ze\))'

" Implementation {{{3
function! lh#cpp#AnalysisLib_Function#AnalysePrototype(prototype)
  " 0- strip comments                            {{{4
  let prototype = substitute(a:prototype, "\\(\\s\\|\n\\)\\+", ' ', 'g')
  let prototype = substitute(prototype, '/\*.\{-}\*/\|//.*$', '', 'g')

  " let prototype = s:StripComments(a:prototype)

  " 1- Qualifier (only one possible in C++)      {{{4
  "   -> virtual / explicit / static
  let qualifier = matchstr  (prototype, s:re_qualifiers)
  let prototype = substitute(prototype, '\s*'.qualifier.'\s*', '', '')

  " 2- Function name                             {{{4
  "   Not supposed to have a scoped qualification
  "   Operators need a special care
  let iName = match(prototype, s:re_qualified_oper)
  "   '.\{-}\ze(' is to match anything till the firt '(' -> convertion
  "   operators
  if iName == -1
    " if not an operator -> just a function
    let iName = match   (prototype, s:re_qualified_name . '\ze(')
    let sName = matchstr(prototype, s:re_qualified_name . '\ze(')
  else
    " echo "operator"
    let sName = matchstr(prototype, s:re_qualified_oper)
  endif
  let sName = matchstr(sName, '^\s*\zs.\{-}\ze\s*$')
  let lName = split(sName, '::')

  " 3- Return type                               {{{4
  let retType = strpart(prototype, 0, iName)
  let retType = matchstr(retType, '^\s*\zs.\{-}\ze\s*$')
  if retType =~ '\~$'  " destructor
    let sName   = retType.sName
    let sName   = matchstr(sName, '^\s*\zs.\{-}\ze\s*$')
    let lName   = split(sName, '::')
    let retType = ''
  endif

  " 4- Parameters                                {{{4
  let params = lh#cpp#AnalysisLib_Function#GetListOfParams(a:prototype)

  " 5- Const member function ?                   {{{4
  let isConst = match(prototype, s:re_const_member_fn) != -1

  " 6- Throw specification                       {{{4
  let sThrowSpec = matchstr(prototype, s:re_throw_spec)
  let lThrowSpec = split(sThrowSpec, '\s*,\s*')
  if len(lThrowSpec) == 0 && match(prototype, s:re_throw_spec) > 0
    let lThrowSpec = [ '' ] 
  endif

  " 7- Result                                    {{{4
  " let result = [ qualifier, retType, lName, params]
  let result = {
	\ "qualifier" : qualifier, 
	\ "return"    : retType,
	\ "name"      : lName,
	\ "parameters": params,
	\ "const"     : isConst,
	\ "throw"     : lThrowSpec
	\}
  return result
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#HaveSameSignature(sig1, sig2) {{{2
" @param[in] sig1 Signature 1 (GetListOfParams() format)
" @param[in] sig2 Signature 2 (GetListOfParams() format)
" @return whether the two signatures are similar (parameters names, default
" parameters and other comment are ignored)
function! lh#cpp#AnalysisLib_Function#HaveSameSignature(sig1, sig2)
  if len(a:sig1) != len(a:sig2) | return 0 | endif
  let i = 0
  while i != len(a:sig1)
    if a:sig1[i][0] != a:sig2[i][0] | return 0 | endif
    let i += 1
  endwhile
  return 1
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SignatureToString(fn) {{{2
function! s:ParamToString(param)
  " 0:Type + 1:param name
  let p = a:param[0] . ' ' .a:param[1]
  return p
endfunction

function! lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn)
  let params = []
  for param in a:fn.parameters
    call add(params, s:ParamToString(param))
  endfor
  let sig = a:fn.name.'(' . join(params, ', ') .')'
  return sig
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SignatureToString(fn) {{{2
" function! lh#cpp#AnalysisLib_Function#IsSame(def, decl)
  " return a:def.name == a:decl[0].name 
	" \ && lh#cpp#AnalysisLib_Function#HaveSameSignature(a:def.parameters, a:decl[0].parameters) 
" endfunction
function! lh#cpp#AnalysisLib_Function#IsSame(def, decl)
  return a:def.name == a:decl.name 
	\ && lh#cpp#AnalysisLib_Function#HaveSameSignature(a:def.parameters, a:decl.parameters) 
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#LoadTags(id) {{{2
function! s:ConvertTag(t)
  let fn_data = {
	\ 'name': a:t.name,
	\ 'parameters': lh#cpp#AnalysisLib_Function#GetListOfParams(a:t.signature),
	\ 'filename': a:t.filename,
	\ 'cmd':a:t.cmd }
  return fn_data
endfunction

function! lh#cpp#AnalysisLib_Function#LoadTags(id)
  let tags = taglist(a:id)
  let declarations = []
  let definitions  = []
  for t in tags
    try
      if     'p' == t.kind
	let fn_data = s:ConvertTag(t)
	if has_key(t, 'access')
	  let fn_data['access'] = t.access
	endif
	call add(declarations , fn_data )
      elseif 'f' == t.kind
	let fn_data = s:ConvertTag(t)
	call add(definitions , fn_data )
	" else ignore
      endif
    catch /.*/
      echomsg "lh#cpp#AnalysisLib_Function#LoadTags(): ".v:exception." in ".string(t)
    endtry
  endfor
  let result = { 'definitions':definitions, 'declarations':declarations }
  return result
endfunction
" }}}2
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SearchUnmatched(fn) {{{2
function! s:SearchUnmatched(functions)
  let unmatched_decl = []
  let unmatched_def = deepcopy(a:functions.definitions)

  for f in a:functions.declarations
    let idx = lh#list#Find_if(unmatched_def, 'lh#cpp#AnalysisLib_Function#IsSame(v:val,v:1_)', [f], 0)
    if idx != -1
      call remove(unmatched_def, idx)
    else
      call add(unmatched_decl, f)
    endif
  endfor

  let unmatched = { 'definitions':unmatched_def, 'declarations':unmatched_decl }
  return unmatched
endfunction

function! lh#cpp#AnalysisLib_Function#SearchUnmatched(what)
  if     type(a:what) == type('string')
    let functions = lh#cpp#AnalysisLib_Function#LoadTags(a:what)
    return s:SearchUnmatched(functions)
  elseif type(a:what) == type({})
    return s:SearchUnmatched(a:what)
  else
    throw "lh#cpp#AnalysisLib_Function#SearchUnmatched: Invalid argument type"
    " We only accept id to fetch with taglist, or list of functions
  endif
endfunction

"------------------------------------------------------------------------
" }}}2

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
