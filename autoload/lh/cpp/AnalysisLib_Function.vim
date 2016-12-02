"=============================================================================
" File:         autoload/lh/cpp/AnalysisLib_Function.vim                  {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/tree/master/License.md>
" Version:      2.2.0
" Created:      05th Oct 2006
" Last Update:  02nd Dec 2016
"------------------------------------------------------------------------
" Description:
"       This plugin defines VimL functions specialized in the analysis of C++
"       code.
"       It can be seen as a library plugin.
"
" Functions Defined:
"       Scope: lh#cpp#AnalysisLib_Function#
"
"       GetFunctionPrototype(lineno, onlyDeclaration)
"               @param lineno           Number of the line where the prototype is fetched
"               @param onlyDeclaration  Restrict to function declarations (1), or
"                                      definition are accepted (0)
"               @return The exact prototype found at the given line
"
"       GetListOfParams(prototype)
"               @param prototype        Prototype to analyse
"               @return a list of [ {type}, {name}, {default value} ], one
"                       for each parameter specified in the prototype
"
"       AnalysePrototype(prototype)
"               @param prototype        Prototype to analyse
"               @return a |dictionary| made of the following fields:
"                       - qualifier: "" / "virtual" / "static" / "explicit"
"                       - return: type of the value returned by the function
"                       - name: list of the scopes + the name of the function
"                       - parameters: @see GetListOfParams
"                       - const: 0/1 whether the function is a const-member "                   function
"                       - throw: list of exception specified in the signature
"
"------------------------------------------------------------------------
" Installation:
"       Drop it into: {rtp}/autoload
"       Requirements: Vim7
" History:
"       v2.2.0
"       (*) Add detection of final, override, constexpr, noexept, volatile,
"          =default, =delete
"       (*) Fix regex building for operator()
"       v2.0.0
"       (*) GPLv3 w/ exception
"       (*) AnalysePrototype() accepts spaces between functionname and (
"       (*) Fix :GOTOIMPL to support operators like +=
"       v1.1.1
"       (*) lh#cpp#AnalysisLib_Function#GetListOfParams() is not messed up by
"       throw-spec
"       v1.0.1:
"       (*) Remembers the parameter is on a new line
"       v1.0.0: First version
"               Code extracted from cpp_GotoFunctionImpl
" TODO:
"       (*) Support template, function types, friends
" }}}1
"=============================================================================


"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" # Debug {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#AnalysisLib_Function#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(...)
  call call('lh#log#this', a:000)
endfunction

function! s:Verbose(...)
  if s:verbose
    call call('s:Log', a:000)
  endif
endfunction

function! lh#cpp#AnalysisLib_Function#debug(expr)
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2
" Function: lh#cpp#AnalysisLib_Function#GetFunctionPrototype " {{{3
" Todo:
" * Retrieve the type even when it is not on the same line as the function
"   identifier.
" * Retrieve the const modifier even when it is not on the same line as the
"   ')'.
function! lh#cpp#AnalysisLib_Function#GetFunctionPrototype(lineno, onlyDeclaration)
  " deprecated
  return lh#dev#c#function#get_prototype(a:lineno, a:onlyDeclaration)
endfunction

" Function: lh#cpp#AnalysisLib_Function#get_prototype(pos, onlyDeclaration) {{{3
" @WARNING: never tested/used function
function! lh#cpp#AnalysisLib_Function#get_prototype(pos, onlyDeclaration) abort
  if type(a:pos) == type(0)
    let lineno = a:pos
    return lh#dev#c#function#get_prototype(lineno, a:onlyDeclaration)
  elseif type(a:pos) == type({}) " this is a tag definition
    " TODO: extract this position rollback code to its own function
    let cleanup = lh#on#exit()
    let filename = a:pos.filename
    let nb_windows = winnr('$')
    let crt_win = winnr()
    call lh#buffer#jump(filename, 'sp')
    if winnr('$') != nb_windows
      call cleanup.register(':q')
    elseif crt_win != winnr()
      call cleanup.register(':'.crt_win.'wincmd w')
    endif
    try
      if a:pos.cmd == '^/'
        let lineno = search(cmd, 'n')
      elseif a:pos.cmd == ':'
        let lineno = eval(a:pos.cmd[1:])
      endif
      if 0 == lineno
        throw "lh-cpp: Impossible to find where prototype for ".(a:pos.name). " is"
      endif
      return lh#dev#c#function#get_prototype(lineno, a:onlyDeclaration)
    finally
      call cleanup.finalize()
    endtry
  endif
endfunction
" }}}3

"------------------------------------------------------------------------
" Function: s:SplitTypeParam(typed_param) {{{3
" @return 4-uple -> [parameter-type, parameter-name, default-value, new-line-before]
" @under deprecation...
function! s:SplitTypeParam(typed_param)
  let pa = lh#dev#option#call('function#_analyse_parameter', &ft, a:typed_param)
  return [pa.type, pa.name, pa.default, pa.nl]
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#GetListOfParams(prototype, mustCleanSpace) {{{3
" todo: beware of exception specifications
" todo: check about of functions types ; to be done with templates... ?
" todo: Arrays of pointers       : "T (*p)[n]"
function! lh#cpp#AnalysisLib_Function#GetListOfParams(prototype, mustCleanSpace)
  " 1- Strip comments and parenthesis
  let prototype = a:prototype
  let prototype = substitute(prototype, '//.\{-}\n', '', 'g')
  let prototype = substitute(prototype, '/\*\_.\{-}\*/', '', 'g')
  " 2- Strip throw spec
  let prototype = substitute(prototype, ')\zs\_s*throw(.*', '', '')

  " 3- convert the string into a list, the separation being done on commas
  let res_params = lh#dev#option#call('function#_signature_to_parameters', &ft, prototype, a:mustCleanSpace)

  return res_params
endfunction
" }}}3

" Function: lh#cpp#AnalysisLib_Function#AnalysePrototype(prototype) {{{3
" @return: {qualifier, return-type, function-name, parameters, throw-spec, const}
" @todo support friends.
" @todo support function types
" @todo support templates
" Constants {{{4
let s:re_qualifiers                 = '\<\%(static\|explicit\|virtual\)\>'

let s:re_qualified_name1            = '\%(::\s*\)\=\<\I\i*\>'
let s:re_qualified_name2            = '\s*::\s*\<\I\i*\>'
let s:re_qualified_name             = s:re_qualified_name1.'\%('.s:re_qualified_name2.'\)*'

let s:re_operators                  = '\<operator\%([=~%+-\*/^&|]\|[]\|()\|&&\|||\|->\|<<\|>>\|==\| \)'
"   What looks like to a "space" operator is actually used in next regex to
"   match convertion operators
let s:re_qualified_oper             = '\%('.s:re_qualified_name . '\s*::\s*\)\=' . s:re_operators . '.\{-}\ze('

let s:re_const_member_fn            = ')\s*\zs\<const\>'
let s:re_volatile_member_fn         = ')\s*\zs\<volatile\>'
let s:re_throw_spec                 = ')\s*\%(\%(\<const\>\|\<volatile\>\)\s\+\)\=\<throw\>(\(\zs.*\ze\))'
let s:re_noexcept_spec              = '\<noexcept\>\((\zs.*\ze)\)\='
let s:re_defined_by_compiler_prefix = ')\s*\%(\%(\<const\>\|\<volatile\>\)\s*\)\=\%(\<noexcept\>\%((.*)\)\=\s*\)\==\s*'
let s:re_pure_virtual               = s:re_defined_by_compiler_prefix . '0\s*[;{]'
let s:re_special_definition         = s:re_defined_by_compiler_prefix . '\zs\<\(default\|delete\)\>\ze\s*[;{]'

let s:re_constexpr                  = '\<constexpr\>'
let s:re_final                      = '\<final\>'
let s:re_override                   = '\<override\>'

" Implementation {{{4
function! lh#cpp#AnalysisLib_Function#AnalysePrototype(prototype)
  " 0- strip comments                            {{{5
  let prototype = substitute(a:prototype, "\\(\\s\\|\n\\)\\+", ' ', 'g')
  let prototype = substitute(prototype, '/\*.\{-}\*/\|//.*$', '', 'g')

  " let prototype = s:StripComments(a:prototype)

  " 1- Qualifier (only one possible in C++)      {{{5
  "   -> virtual / explicit / static
  let qualifier = matchstr  (prototype, s:re_qualifiers)
  let prototype = substitute(prototype, '\s*'.qualifier.'\s*', '', '')

  " 2- Function name                             {{{5
  "   Not supposed to have a scoped qualification
  "   Operators need a special care
  let iName = match(prototype, s:re_qualified_oper)
  "   '.\{-}\ze(' is to match anything till the firt '(' -> convertion
  "   operators
  if iName == -1
    " if not an operator -> just a function
    " "\s*(" -> parenthesis may be aligned and not sticking to the function
    " name
    let iName = match   (prototype, s:re_qualified_name . '\ze\s*(')
    let sName = matchstr(prototype, s:re_qualified_name . '\ze\s*(')
  else
    " echo "operator"
    let sName = matchstr(prototype, s:re_qualified_oper)
  endif
  let sName = matchstr(sName, '^\s*\zs.\{-}\ze\s*$')
  let lName = split(sName, '::')

  " 3- Return type                               {{{5
  let retType = strpart(prototype, 0, iName)
  let retType = matchstr(retType, '^\s*\zs.\{-}\ze\s*$')
  if retType =~ '\~$'  " destructor
    let sName   = retType.sName
    let sName   = matchstr(sName, '^\s*\zs.\{-}\ze\s*$')
    let lName   = split(sName, '::')
    let retType = ''
  endif
  let retType = substitute(retType, s:re_constexpr.'\s*', '', '')

  " 4- Parameters                                {{{5
  let sParams = strpart(prototype, iName+len(sName))
  let params = lh#cpp#AnalysisLib_Function#GetListOfParams(sParams, 0)

  " 5- Const member function ?                   {{{5
  let isConst    = match(prototype, s:re_const_member_fn) != -1
  let isVolatile = match(prototype, s:re_volatile_member_fn) != -1

  " 6- Throw specification                       {{{5
  let sThrowSpec = matchstr(prototype, s:re_throw_spec)
  let lThrowSpec = split(sThrowSpec, '\s*,\s*')
  if len(lThrowSpec) == 0 && match(prototype, s:re_throw_spec) > 0
    let lThrowSpec = [ '' ]
  endif
  let sNoexceptSpec = matchstr(prototype, s:re_noexcept_spec)

  " 7- Pure member function ?                    {{{5
  let isPure =  prototype =~ s:re_pure_virtual

  " 8- =default/=delete ?                        {{{5
  let special_definition =  matchstr(prototype, s:re_special_definition)

  " 9- final/override ?                          {{{5
  let isFinal     = prototype =~ s:re_final
  let isOverriden = prototype =~ s:re_override

  " 10- constexpr ?                              {{{5
  let isConstexpr = prototype =~ s:re_constexpr

  " *- Result                                    {{{5
  " let result = [ qualifier, retType, lName, params]
  let result =
        \ { "qualifier"          : qualifier
        \ , "return"             : retType
        \ , "name"               : lName
        \ , "parameters"         : params
        \ , "constexpr"          : isConstexpr
        \ , "const"              : isConst
        \ , "volatile"           : isVolatile
        \ , "pure"               : isPure
        \ , "special_definition" : special_definition
        \ , "throw"              : lThrowSpec
        \ , "noexcept"           : sNoexceptSpec
        \ , "final"              : isFinal
        \ , "overriden"          : isOverriden
        \ }
  return result
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#HaveSameSignature(sig1, sig2) {{{3
" @param[in] sig1 Signature 1 (GetListOfParams() format)
" @param[in] sig2 Signature 2 (GetListOfParams() format)
" @return whether the two signatures are similar (parameters names, default
" parameters and other comment are ignored)
function! lh#cpp#AnalysisLib_Function#HaveSameSignature(sig1, sig2)
  return a:sig1 == a:sig2

  if len(a:sig1) != len(a:sig2) | return 0 | endif
  let i = 0
  while i != len(a:sig1)
    if a:sig1[i] != a:sig2[i] | return 0 | endif
    let i += 1
  endwhile
  return 1
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SignatureToString(fn) {{{3
function! s:ParamToString(param)
  " 0:Type + 1:param name
  let p = (a:param.type) . ' ' .(a:param.name)
  return p
endfunction

function! lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn)
  let params = []
  for param in a:fn.parameters
    call add(params, s:ParamToString(param))
  endfor
  let sig = a:fn.name.'(' . join(params, ', ') .')'
  if a:fn.const
    let sig .= ' const'
  endif
  return sig
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SignatureToString(fn) {{{3
" function! lh#cpp#AnalysisLib_Function#IsSame(def, decl)
  " return a:def.name == a:decl[0].name
        " \ && lh#cpp#AnalysisLib_Function#HaveSameSignature(a:def.parameters, a:decl[0].parameters)
" endfunction
function! lh#cpp#AnalysisLib_Function#IsSame(def, decl)
  let res = a:def.name == a:decl.name
        \ && lh#cpp#AnalysisLib_Function#HaveSameSignature(a:def.parameters, a:decl.parameters)
  " if a:def.name == a:decl.name
    " echomsg res ."[".(a:def.name)."] <- " . string(a:def.parameters) . ' <--> ' . string(a:decl.parameters)
  " endif
  return res
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#LoadTags(id) {{{3
function! s:ConvertTag(t) abort
  let fn_data = {
        \ 'name'          : a:t.name,
        \ 'signature'     : a:t.signature,
        \ 'parameters'    : lh#cpp#AnalysisLib_Function#GetListOfParams(a:t.signature, 1),
        \ 'const'         : match(a:t.signature, s:re_const_member_fn) != -1,
        \ 'filename'      : a:t.filename,
        \ 'implementation': get(a:t, 'implementation', ''),
        \ 'class'         : get(a:t, 'class', ''),
        \ 'cmd'           : a:t.cmd }
  if has_key(a:t, 'access')
    let fn_data['access'] = a:t.access
  endif
  return fn_data
endfunction

function! lh#cpp#AnalysisLib_Function#LoadTags(id) abort
  let tags = taglist(a:id)
  call s:Verbose('%1 functions definitions & declarations matching %2 found', len(tags), a:id)

  " # Definitions (f)
  let f_tags = filter(copy(tags), 'v:val.kind == "f"')
  let definitions = map(copy(f_tags), 's:ConvertTag(v:val)')
  call s:Verbose('%1 functions definitions found', len(definitions))
  " Remove inline definitions
  " -> a definition with an access specifier is an inline definition
  call filter(definitions, '! has_key(v:val, "access")')
  " -> We can also use universal ctags {c++.properties} field option
  call filter(definitions, 'get(v:val, "properties","") =~ "inline"')
  call s:Verbose('%1 functions definitions kept (class-inline definitions removed)', len(definitions))

  " # Declarations (p)
  let p_tags = filter(copy(tags), 'v:val.kind == "p"')
  let declarations = map(copy(p_tags), 's:ConvertTag(v:val)')
  call s:Verbose('%1 functions declarations found', len(declarations))

  " Remove "= 0"
  call filter(declarations, 'v:val.implementation !~ "pure"')
  call s:Verbose('%1 functions declarations kept (pure virtual function removed)', len(declarations))
  " Remove "= default" & "= delete"
  " -> not present in the signature.
  " -> at best, it may be in the command
  call filter(declarations, 'v:val.cmd !~ "=\\v\\s*(default|delete)"')
  " -> We can also use universal ctags {c++.properties} field option
  call filter(declarations, 'get(v:val, "properties","") =~ "default\\|delete"')
  call s:Verbose('%1 functions declarations found and kept (defaulted/deleted function removed)', len(declarations))

  let result = { 'definitions':definitions, 'declarations': declarations }
  return result
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SearchUnmatched(fn) {{{3
function! s:CmpSig(lhs, rhs)
  if     len(a:lhs) < len(a:rhs) | return -1
  elseif len(a:lhs) > len(a:rhs) | return  1
  else
    let i = 0
    while i != len(a:rhs)
      if     a:lhs[i] < a:rhs[i] | return -1
      elseif a:lhs[i] > a:rhs[i] | return  1
      endif
      let i += 1
    endwhile
    return 0
  endif
endfunction

function! lh#cpp#AnalysisLib_Function#_ByNameAndSig(lhs, rhs)
  let res = a:lhs.name <  a:rhs.name ? -1
        \ : a:lhs.name == a:rhs.name ? s:CmpSig(lh#list#get(a:lhs.parameters,'type'), lh#list#get(a:rhs.parameters, 'type'))
        \ :                             1
  return res
endfunction

function! s:SearchUnmatched(functions)
  let decls = sort(a:functions.declarations, function('lh#cpp#AnalysisLib_Function#_ByNameAndSig'))
  call s:Verbose('%1 function declarations sorted', len(a:functions.declarations))
  let defs  = sort(a:functions.definitions,  function('lh#cpp#AnalysisLib_Function#_ByNameAndSig'))
  call s:Verbose('%1 function definitions sorted', len(a:functions.definitions))

  let unmatched_decl = []
  let unmatched_def  = []
  call lh#list#concurrent_for(a:functions.declarations, a:functions.definitions,
        \ unmatched_decl, unmatched_def, [],
        \ function('lh#cpp#AnalysisLib_Function#_ByNameAndSig'))
  let unmatched = { 'definitions':unmatched_def, 'declarations':unmatched_decl }
  call s:Verbose('Symetric difference between function definitions and declarions done')
  return unmatched
endfunction

function! lh#cpp#AnalysisLib_Function#SearchUnmatched(what) abort
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
" Function: lh#cpp#AnalysisLib_Function#SearchAllDeclarations(fn) {{{3
" inline member function are seen as "p" (instead of "f") by ctags, hence this
" function
function! lh#cpp#AnalysisLib_Function#SearchAllDeclarations(functions)
  let declarations = deepcopy(a:functions.declarations)
  let unmatched_def = copy(a:functions.definitions)

  for f in declarations
    let idx = lh#list#Find_if(unmatched_def, 'lh#cpp#AnalysisLib_Function#IsSame(v:val,v:1_)', [f], 0)
    if idx != -1
      call remove(unmatched_def, idx)
    endif
  endfor

  " That is not a very good way to identify inline functions, at least all
  " inline function are still kept
  call extend(declarations, unmatched_def)
  return declarations
endfunction
"------------------------------------------------------------------------
" }}}3
"------------------------------------------------------------------------
" Function! lh#cpp#AnalysisLib_Function#SignatureToSearchRegex2(signature,className) {{{3
" todo:
" - ignore default arguments
" - template types like std::auto_ptr<foo::bar>
function! s:Type2Regex(type, param)
  let type = a:type
  "
  " let id = (""!=ptr) ? ' ( \* \%(\<\I\i*\>\)\= ) ' : ' \%(\<\I\i*\>\)\= '
  let id =  strlen(a:param) ? ' \%(\<\I\i*\>\)\= ' : ''
  " arrays
  let array = matchstr(a:param, '\[.*\]')

  " escape arrays and pointers characters
  let type = substitute(type, '\s*\([[\]*]\)\s*', ' \\\1 ', 'g')
  let type = substitute(type, '\s*&\s*', ' \0 ', 'g')
  let array = substitute(array, '\s*\([[\]*]\)\s*', ' \\\1 ', 'g')
  " echomsg a:param . ' -> ' . type
  let re_param = type . ' ' . id . ' ' . array
  return re_param
endfunction

function! lh#cpp#AnalysisLib_Function#SignatureToSearchRegex2(signature,className)
  let function_data = lh#cpp#AnalysisLib_Function#AnalysePrototype(a:signature)

  " Return type {{{4
  let impl2search = ''
  if strlen(function_data.return) > 0
  let impl2search .= s:Type2Regex(function_data.return, '') . ' '
  endif

  " Class::functionname {{{4
  let className = a:className . (""!=a:className ? '::' : '')
  if className =~ '#::#'
    let ns = matchstr(className, '^.*\ze#::#') . '::'
    let b = substitute(ns, '[^:]', '', 'g')
    let b = substitute(b, '::', '\\%(', 'g')
    let ns_re = b.substitute(ns, '\<\I\i*\>::', '\0\\)\\=', 'g')
    let cl_re = matchstr(className, '#::#\zs.*$')
    let className = ns_re.cl_re
  endif
  let className   = substitute(className, '\s*::\s*', ' :: ', 'g')
  let name = className . join(function_data.name, ' :: ')
  let impl2search .= escape(name, '~')

  " Parameters {{{4
  let params = []
  for param in function_data.parameters
    call add(params, s:Type2Regex(param[0], param[1]))
  endfor
  let impl2search .= ' ( ' . join(params, ' , ').' )'

  let impl2search .= function_data.const ? ' const' : ''


  " Spaces & comments -> '\(\_s\|/\*.\{-}\*/\|//.*$\)*' and \i {{{4
  let impl2search = substitute(impl2search, '\s\{2,}', ' ', 'g')
  let g:impl2search2 = impl2search

  let impl2search = substitute(' \zs'.impl2search, ' ',
        \ '\\%(\\_s\\|/\\*.\\{-}\\*/\\|//.*$\\)*', 'g')
  " Note: \%(\) is like \(\) but the subexpressions are not counted.
  " Note: ' \zs' inserted at the start of the regex helps ignore any comments
  " before the signature of the function.
  " Return the regex built {{{4
  "
  " Check pure virtual functions: {{{4
  let isPure =  function_data.pure

  " Check =delete/=default functions: {{{4
  let isWithoutDefinition = !empty(function_data.special_definition)

  let res = {'regex':impl2search, 'ispure':isPure, 'isWithoutDefinition': isWithoutDefinition}
  return res
endfunction

" Function! lh#cpp#AnalysisLib_Function#SignatureToSearchRegex(signature,className) {{{3
function! lh#cpp#AnalysisLib_Function#SignatureToSearchRegex(signature,className)
  let g:signature = a:signature
  let g:className = a:className
  " trim spaces {{{4
  let impl2search = substitute(a:signature, "\\(\\s\\|\n\\)\\+", ' ', 'g')
  " trim comments {{{4
  let impl2search = substitute(impl2search, '/\*.\{-}\*/\|//.*$', '', 'g')
  " destructor ? {{{4
  let impl2search = substitute(impl2search, '\~', '\\\0', 'g')
  " '[,' '],' pointers {{{4
    " let impl2search = substitute(impl2search, '\s*\([[\]*]\)\s*', ' \\\1 ', 'g')
    " Note: these characters will be backspaced into s:TrimParametersNames
  " echo impl2search
  let impl2search = substitute(impl2search, '\s*\([[\]*]\)\s*', ' \1 ', 'g')
    " However returned pointers must be backspaced
    let retTypePos = matchend(impl2search, '.\{-}\s\+\ze\i\{-}\s*(\|\ze\<operator\>')
    let retType       = strpart(impl2search, 0, retTypePos)
    let func_n_params = strpart(impl2search, retTypePos)
    let retType = substitute(retType, '\s*\([[\]*]\)\s*', ' \\\1 ', 'g')
    let impl2search = retType . func_n_params
  " operator* {{{4
  let impl2search = substitute(impl2search, 'operator\s*\*', 'operator \\*', '')
  "  <, >, =, (, ), ',' and references {{{4
  let impl2search = substitute(impl2search, '\s*\([-+*/%^=<>!]=\|&&\|||\|[<>=(),&]\)\s*', ' \1 ', 'g')
  " Check pure virtual functions: {{{4
  let isPure =  impl2search =~ '=\s*0\s*;\s*$'
  " Check =delete/=default functions: {{{4
  let isWithoutDefinition = impl2search =~ '=\s*\<\(default\|delete\)\>\s*;\s*$'
  " Start and end {{{4
  let impl2search = substitute(impl2search, '^\s*\|\s*;\s*$', '', 'g')
  " Default parameters -> comment => ignored along with spaces {{{4
  " -> recognize "=" to strip what follows when not operator[-+*/=!^]=
  let impl2search = substitute(impl2search, '\%(\<operator\>\s*\([-+*/=!^%]\s*\)\=\)\@<!=[^,)]\+', '', 'g')
  " virtual, static and explicit -> comment => ignored along with spaces {{{4
  let impl2search = substitute(impl2search,
        \ '\_s*\<\%(virtual\|static\|explicit\)\>\_s*', '', 'g')
  " Trim the variables names {{{4
  " Todo: \(un\)signed \(short\|long\) \(int\|float\|double\)
  "       const, *
  "       First non spaced type + exceptions like: scope\s*::\s*type ,
  "       class<xxx,yyy> (scope or type)
  let impl2search = lh#cpp#AnalysisLib_Function#TrimParametersNames(impl2search)
  " class name {{{4
  let className = a:className . (""!=a:className ? '::' : '')
  if className =~ '#::#'
    let ns = matchstr(className, '^.*\ze#::#') . '::'
    let b = substitute(ns, '[^:]', '', 'g')
    let b = substitute(b, '::', '\\%(', 'g')
    let ns_re = b.substitute(ns, '\<\I\i*\>::', '\0\\)\\=', 'g')
    let cl_re = matchstr(className, '#::#\zs.*$')
    let className = ns_re.cl_re
  endif
  let className   = substitute(className, '\s*::\s*', ' :: ', 'g')
  " let g:className = className
  " and finally inject the class name patten in the search pattern
  " NB: operators have a special treatment
  let impl2search = substitute(impl2search,
        \ '\%(\\\~\)\=\<\I\i*\>\_s*(\|\<operator\>',
        \ escape(className, '\' ) .'\0', '')
  " echo impl2search
  let g:impl2search1 = impl2search

  " Spaces & comments -> '\(\_s\|/\*.\{-}\*/\|//.*$\)*' and \i {{{4
  " let impl2search = substitute(' \zs'.impl2search, ' ',
  let impl2search = substitute(impl2search, ' ',
        \ '\\%(\\_s\\|/\\*.\\{-}\\*/\\|//.*$\\)*', 'g')
  " Note: \%(\) is like \(\) but the subexpressions are not counted.
  " Note: ' \zs' inserted at the start of the regex helps ignore any comments
  " before the signature of the function.
  " Return the regex built {{{4
  "
  let res = {'regex':impl2search, 'ispure':isPure, 'isWithoutDefinition': isWithoutDefinition}
  return res
endfunction "}}}4
"------------------------------------------------------------------------
" Function: s:TrimParametersNames(str) {{{3
" Some constant regexes {{{4
let s:type_sign = 'unsigned\|signed'
let s:type_size = 'short\|long'
let s:type_main = 'void\|char\|int\|float'
let s:type_simple = s:type_sign.'\|'.s:type_size.'\|'.s:type_main
let s:type_scope1 = '\%(::\s*\)\=\<\I\i*\>'
let s:type_scope2 = '\s*::\s*\<\I\i*\>'
let s:type_scope  = s:type_scope1.'\%('.s:type_scope2.'\)*'
let s:re = '^\s*\%(\<const\>\s*\)\='.
      \ '\%(\%('.s:type_simple.'\|\s\+\)\+\|'.s:type_scope.'\)'.
      \ '\%(\<const\>\|\*\|&\|\s\+\)*'
" }}}4
function! lh#cpp#AnalysisLib_Function#TrimParametersNames(str)
  " Stuff Supported: {{{4
  " - Simple parameters          : "T p"
  " - Arrays                     : "T p[][n]"
  " - Arrays of pointers         : "T (*p)[n]"
  " - Scopes within complex types: "T1::T2"
    " Todo: support templates like "A<B,C>"
    " Todo: support functions like "T (*NameF)(P1, P2, ...)" ,
    "                              "T (CL::* pmf)(params)"
  " }}}4
  " Cut the signature in order to concentrate on the most outer parenthesis
  let head_end = matchend(a:str, '^\([^(]\{-}\<operator\>\s*(\s*)\s*\|[^(]*\)(') " take operator() into account
  let head = a:str[ : head_end]
  let tail = matchstr(a:str, ')[^)]*$', head_end-1)
  let params = matchstr(a:str, '^[^(]*(\zs.*\ze)[^)]*$', head_end-1)
  let params_types = ''
  " Loop on the parameters
  while '' != params
    " Get the parameter field
    let field  = matchstr(params, '^[^,]*')
    let params = matchstr(params, ',\zs.*$')

    " Handle case of arrays {{{5
    let p = 0
    let array = ''
    while -1 != p
      let p = match(field, '\[.\{-}\]', p)
      if -1 == p | break | endif
      let array = array . escape(matchstr(field, '\[.\{-}\]', p), '[]')
      let p = p + 1
    endwhile " }}}4
    " Extract the type of the parameter and only the type
    let type = matchstr(field, s:re)
    " let type = matchstr(field, '^\s*\(\<const\>\s*\)\='.
          " \ '\(\('.s:type_simple.'\|\s\+\)\+\|\<\I\i*\>\)'.
          " \ '\(\<const\>\|\*\|&\|\s\+\)*')
    " Check for special pointers stuff "T (*p_id)"
    let ptr = matchstr(field, '(\s*\*\s*\(\<\I\i*\>\)\=\s*)')
    let id = (""!=ptr) ? ' ( \* \%(\<\I\i*\>\)\= ) ' : ' \%(\<\I\i*\>\)\= '
    " Build the regex containing the parameter type, spaces, etc
    let params_types = params_types.','.
          \ escape(type, '*')
          \ . id
          \ . array
          " \ type.'\%(\<\I\i*\>\)\= '
  endwhile

  " Return the final regex to search.
  return substitute(head . strpart(params_types,1) . tail, '\s\s\+', ' ', 'g')
endfunction
" }}}3
"------------------------------------------------------------------------
" }}}2

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
