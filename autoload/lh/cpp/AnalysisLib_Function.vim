"=============================================================================
" File:         autoload/lh/cpp/AnalysisLib_Function.vim                  {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/tree/master/License.md>
" Version:      2.3.0
" Created:      05th Oct 2006
" Last Update:  09th Apr 2021
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
"       v2.3.0
"       (*) Improve/fix Vim based :Override command
"       v2.2.0
"       (*) Add detection of final, override, constexpr, noexept, volatile,
"          =default, =delete
"       (*) Fix regex building for operator()
"       (*) Support `decltype(auto)`
"       (*) Support `->` return type specification
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
let s:k_not_available = lh#option#unset('libclang cannot tell')

" " Function: lh#cpp#AnalysisLib_Function#get_function_info(lineno, onlyDeclaration, returnEndProtoExtent) {{{3
" Global fields:
" - "name"               = name of the function
" - "qualifier"          = "static" | "virtual" | "explicit"
" - "scope"              = reversed list of "name", "kind", ["tparams"]
" - "return"             = "" or spelling of the return type
" - "throw"              = C++98 complete throw-specification, if any
" - "noexcept"           = C++11 exception specification
" - "signature"          = As returned by libclang (-> const-westified)
" - "fullsignature"      = Reconstructed to match exact spelling in declaration
" - "parameters"         = List of parameters
"                          - "name"            : parameter name
"                          - "type"            : west-constified type
"                          - "type_as_typed"   : type exactly as it was spelled
"                          - "nl"              : bool (newline ?)
"                          - "full_spelling"   : exact spelling of everything
"                          - "full_wo_default" : exact spelling of everything
"                                                but the default value
" - "tparams"            = List of template parameters
          \ 'spelling' : py_param.spelling
          \,'what'     : py_param.what
          \,'extent'   : py_param.extent
          \,'nl'       : last_line >= 0 && last_line != py_param.extent.start.lnum
" - "body_extent"        = extent of the body
" Fields that makes sense only w/ member functions
" - "pure"               = bool
" - "final"              = bool
" - "overriden"          = bool
" - "special_definition" = "= default" | "= delete"
" - "const"              = bool
" - "volatile"           = bool
" - "ref_qualifier"      = "" | "lvalue" | "rvalue"
" - "special_func"       =
function! lh#cpp#AnalysisLib_Function#_libclang_get_function_info(lineno, onlyDeclaration, returnEndProtoExtent) abort
  " Make sure the cursor is onto something...
  if getline('.')[:col('.')-1] =~ '^\s*$'
    normal! ^
  endif
  let py_info = clang#get_symbol('function')
  if py_info is v:none
    throw "Cannot decode a function with libclang."
  endif
  if (get(py_info, 'is_definition', 0) && a:onlyDeclaration)
    return {}
  endif

  let [sNoexceptSpec, idx_s, idx_e] = lh#string#matchstrpos(py_info.type.spelling, s:re_noexcept_spec)
  call s:Verbose("sNoexceptSpec: %1 ∈ [%2, %3]", sNoexceptSpec, idx_s, idx_e)
  let [sThrowSpec, idx_s, idx_e] = lh#string#matchstrpos(py_info.type.spelling, s:re_throw_spec)
  if idx_s >= 0
    let lThrowSpec = split(sThrowSpec, '\s*,\s*', 1)
  else
    let lThrowSpec = []
  endif

  let info = {}
  let info.qualifier
        \ = py_info.static   ? 'static'
        \ : py_info.virtual  ? 'virtual'
        \ : py_info.explicit ? 'explicit'
        \ : ''
  " As of 9, libclang still cannot tell whether a constructor is
  " declared explicit
  " TODO: Some outer scopes may be template classes actually
  let info.scope         = py_info.scope
  " libclang may introduce spaces where there is none
  " Not sure how to extract everything from the returned type
  let info.return        = py_info.true_kind =~ '\vCONSTRUCTOR|DESTRUCTOR'
        \ ? ''
        \ : py_info.result_type.spelling
  let info.name          = py_info.spelling
  " let info.constexpr     = s:k_not_available
  let info.const         = py_info.const
  let info.volatile      = py_info.type.spelling =~ '\v<volatile>'
  let info.ref_qualifier = py_info.type.ref_qualifier
  let info.pure          = py_info.pure
  let info.special_definition
        \ = py_info.is_defaulted ? '= default'
        \ : py_info.is_deleted   ? '= delete'
        \ : ''
  let info.throw          = lThrowSpec
  let info.noexcept       = sNoexceptSpec
  let info.final          = py_info.final
  let info.overriden      = py_info.override
  let info.signature      = py_info.type.spelling
  if empty(info.return)
    " Remove "void" from Constructor/Destructor signature
    " I don't know why libclang add this "void" in te spelling
    let info.signature = substitute(info.signature, '^void\s*', '', 'g')
  endif
  let info.fullsignature  = substitute(info.signature, '(', info.name.'(', '')
  let info.parameters     = []
  " TODO: analyse get_tokens() to be more precise
  let last_line = -1
  for py_param in py_info.parameters
    let full = join(clang#extract_from_extent(py_param.extent, 'Parameter'), "\n")
    " libclang does tell the default value
    " so if there is a default value, it'd be after the parameter name only
    " (need to ignore cases like "type<stuf=42>")
    " TODO: if parameter has no name, do not try the next matchlist()
    let [all, head, def; rest] = matchlist(full, '\v(.{-}<'.(py_param.spelling).'>[^=]{-})%(\s*\=\s*(.*))=')
    " Using function#_analyse_parameter to get full type spelling (without any
    " alteration like merged spaces). While the function also returns the
    " default, it's likelly to be less precise than the previous test that
    " knows the parameter name.
    let clean_param = full
    let clean_param = substitute(clean_param, '//.\{-}\n', '', 'g')
    let clean_param = substitute(clean_param, '/\*\_.\{-}\*/', '', 'g')

    let pa = lh#dev#option#call('function#_analyse_parameter', &ft, clean_param, {'expected_param_name': py_param.spelling, 'must_clean_space': 0})
    let lnum = py_param.extent.start.lnum
    let col  = py_param.extent.start.col
    let nl =   (last_line == -1 && lh#encoding#strpart(getline(lnum), 0, col-1) =~ '^\s*$')
          \ || (last_line >=  0 && last_line != lnum)
    let param = {
          \ 'name'            : py_param.spelling
          \,'type'            : py_param.type.spelling
          \,'type_as_typed'   : pa.type
          \,'nl'              : nl
          \,'full_spelling'   : full
          \,'full_wo_default' : head
          \ }
    if !empty(def)
      let param.default = def
      let param.default_vimscript = pa.default
    endif
    " \,'default': s:k_not_available
    let info.parameters += [param]
    let last_line = py_param.extent.end.lnum
  endfor
  let info.tparams       = []
  " TODO: analyse get_tokens() to be more precise
  let last_line = py_info.extent.start.lnum
  for py_param in py_info.template_parameters
    let param = {
          \ 'spelling' : py_param.spelling
          \,'what'     : py_param.what
          \,'extent'   : py_param.extent
          \,'nl'       : last_line >= 0 && last_line != py_param.extent.start.lnum
          \ }
    " \,'default': s:k_not_available
    let info.tparams += [param]
    let last_line = py_param.extent.end.lnum
  endfor
  " TODO: analyse get_tokens() to know whether there is a new line after
  " template<....>, the type, the func name...
  let info.special_func
        \ = py_info.true_kind == 'CursorKind.CONSTRUCTOR' ? py_info.constructor_kind . (empty(py_info.constructor_kind)?'':' ').'constructor'
        \ : py_info.true_kind == 'CursorKind.DESTRUCTOR' ? 'destructor'
        \ : info.name == 'operator='
        \   ? (info.parameters[0].type =~ 'const' ? 'copy-assignment operator'
        \     :info.parameters[0].type =~ '&&'    ? 'move-assignment operator'
        \     :                                     'assignment operator'
        \ )
        \ : ''
  if py_info.is_definition
    call lh#assert#value(py_info.children).has_key('CursorKind.COMPOUND_STMT')
    let body_extent = py_info.children['CursorKind.COMPOUND_STMT'][0].extent
    call s:Verbose('body_extent: %1', body_extent)
    let info.body_extent = body_extent

    " Extract init-list in case of a constructor
    if py_info.true_kind == 'CursorKind.CONSTRUCTOR'
      let full_extent = py_info.extent
      let mrefs = get(py_info.children, 'CursorKind.MEMBER_REF', [])
      call s:Verbose("Member refs: %1", mrefs)
      if !empty(mrefs)  " there is an initialiser-list!
        let mref_extents = lh#list#get(mrefs, 'extent')
        call s:Verbose('full_extent: %1', full_extent)
        call s:Verbose('mref_extents: %1', mref_extents)
        let k_fact = 1000000
        let starts = map(copy(mref_extents), 'v:val.start.lnum * k_fact + v:val.start.col')
        let first_mref = min(starts)
        let col = first_mref % k_fact
        call cursor(first_mref / k_fact, col)
        call s:Verbose("Cursor: %1", getcurpos())
        if 0
          let colon_pos = searchpos('\v\_s*:\_s*%#', 'bWnc')
        else
         if  search('\v\)(\s*noexcept)=\zs', 'bWc') == 0
           let colon_pos = [0,0]
         else
           exe "normal! \<right>"
           let colon_pos = getcurpos()[1:]
         endif
        endif
        call s:Verbose('starts: %1', starts)
        call s:Verbose('1srt mref: %1', first_mref)
        call s:Verbose('colon_pos: %1', colon_pos)
        if colon_pos == [0, 0]
          call lh#common#warning_msg('Cannot find the start of the initialiser-list...')
        else
          let info.init_list_extent = {'filename': body_extent.filename,
                \ 'start': {'lnum': colon_pos[0], 'col': colon_pos[1]},
                \ 'end' : clang#prev_position(body_extent.start)}
        endif
      endif
    endif
  endif
  let info.start = py_info.extent.start
  let info.end   = py_info.extent.end
  let info.end_proto = [0, info.end.lnum, info.end.col-1, 0]
  return info
endfunction

function! lh#cpp#AnalysisLib_Function#get_function_info(lineno, onlyDeclaration, returnEndProtoExtent) abort
  try
    if lh#has#plugin('autoload/clang.vim') && clang#can_plugin_be_used()
      let info = lh#cpp#AnalysisLib_Function#_libclang_get_function_info(a:lineno, a:onlyDeclaration, a:returnEndProtoExtent)
      if !empty(info)
        return info
      endif
    endif
  catch /.*/
    call lh#common#warning_msg("We cannot use vim-clang+libclang to decode function prototype, falling back to pure vimscript analysis: ".v:exception)
    if s:verbose
      let qf = lh#exception#decode(v:throwpoint).as_qf('')
      let qf[0].text = substitute(qf[0].text, '^\.\.\.', v:exception, '')
      call setqflist(reverse(qf))
      if exists(':Copen')
        Copen
      else
        copen
      endif
    endif
  endtry

  " else: If vim-clang + libclang could not be used....
  let proto = lh#dev#c#function#get_prototype(a:lineno, a:onlyDeclaration, a:returnEndProtoExtent)
  let fullsignature = a:returnEndProtoExtent ? proto[1] : proto
  let info  = lh#cpp#AnalysisLib_Function#AnalysePrototype(fullsignature)
  let info.fullsignature = fullsignature
  let info.end_proto = a:returnEndProtoExtent ? proto[0] : 42
  return info
endfunction

" Function: lh#cpp#AnalysisLib_Function#GetFunctionPrototype " {{{3
" Todo:
" * Retrieve the type even when it is not on the same line as the function
"   identifier.
" * Retrieve the const modifier even when it is not on the same line as the
"   ')'.
function! lh#cpp#AnalysisLib_Function#GetFunctionPrototype(lineno, onlyDeclaration) abort
  call lh#notify#deprecated('lh#cpp#AnalysisLib_Function#GetFunctionPrototype', 'lh#dev#c#function#get_prototype')
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
" Function: lh#cpp#AnalysisLib_Function#GetListOfParams(prototype, mustCleanSpace) {{{3
" todo: beware of exception specifications
" todo: check about of functions types ; to be done with templates... ?
" todo: Arrays of pointers       : "T (*p)[n]"
function! lh#cpp#AnalysisLib_Function#GetListOfParams(prototype, mustCleanSpace) abort
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
" let s:re_noexcept_spec              = ')\s*\%(\%(\<const\>\|\<volatile\>\)\s\+\)\=\<noexcept\>\((\zs.*\ze)\)\='
let s:re_noexcept_spec              = '\<noexcept\>\%((\zs.*\ze)\)\='
let s:re_defined_by_compiler_prefix = ')\s*\%(\%(\<const\>\|\<volatile\>\)\s*\)\=\%(\<noexcept\>\%((.*)\)\=\s*\)\==\s*'
let s:re_pure_virtual               = s:re_defined_by_compiler_prefix . '0\s*[;{]'
let s:re_special_definition         = s:re_defined_by_compiler_prefix . '\zs\<\(default\|delete\)\>\ze\s*[;{]'

let s:re_constexpr                  = '\<constexpr\>'
let s:re_final                      = '\<final\>'
let s:re_override                   = '\<override\>'

" Implementation {{{4
function! lh#cpp#AnalysisLib_Function#AnalysePrototype(prototype) abort
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

    " First: special case of `decltype(auto)`
    let iName = match   (prototype, 'decltype(auto)\s*\zs'.s:re_qualified_name . '\ze\s*(')
    if  iName >= 0
      let sName = matchstr(prototype, 'decltype(auto)\s*\zs'.s:re_qualified_name . '\ze\s*(')
    else
      " "\s*(" -> parenthesis may be aligned and not sticking to the function
      " name
      let iName = match   (prototype, s:re_qualified_name . '\ze\s*(')
      let sName = matchstr(prototype, s:re_qualified_name . '\ze\s*(')
    endif
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
  if retType =~ '\v^$|auto' && prototype =~ '->'
    " New C++11 syntax for return type specification
    let retType = matchstr(prototype, '\v-\>\s*\zs.{-}\ze\s*[{;]\s*$')
    let prototype = matchstr(prototype, '\v^.{-}\ze\s*-\>')
  endif

  " 4- Throw specification                       {{{5
  let sThrowSpec = matchstr(prototype, s:re_throw_spec)
  let lThrowSpec = split(sThrowSpec, '\s*,\s*')
  if len(lThrowSpec) == 0 && match(prototype, s:re_throw_spec) > 0
    let lThrowSpec = [ '' ]
  endif
  let [sNoexceptSpec, idx_s, idx_e] = lh#string#matchstrpos(prototype, s:re_noexcept_spec)
  call s:Verbose("sNoexceptSpec: %1 ∈ [%2, %3]", sNoexceptSpec, idx_s, idx_e)
  if !empty(sNoexceptSpec)
    " call s:Verbose("Prototype before trimming noexcept(): %1", prototype)
    let prototype = prototype[:idx_s-2].prototype[idx_e+1:]
    " +2: to remove () that'll mess param extraction
    call s:Verbose("Prototype after trimming noexcept(): %1", prototype)
  endif

  " 5- Parameters                                {{{5
  let sParams = strpart(prototype, iName+len(sName))
  let params = lh#cpp#AnalysisLib_Function#GetListOfParams(sParams, 0)

  " 6- Const member function ?                   {{{5
  let isConst    = match(prototype, s:re_const_member_fn) != -1
  let isVolatile = match(prototype, s:re_volatile_member_fn) != -1

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
function! lh#cpp#AnalysisLib_Function#HaveSameSignature(sig1, sig2) abort
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
function! s:ParamToString(param) abort
  " 0:Type + 1:param name
  let p = (a:param.type) . ' ' .(a:param.name)
  return p
endfunction

function! lh#cpp#AnalysisLib_Function#BuildSignatureAsString(fn) abort
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
function! lh#cpp#AnalysisLib_Function#IsSame(def, decl) abort
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

function! lh#cpp#AnalysisLib_Function#LoadTags(id, ...) abort
  let options = get(a:, 1, {})
  let tags = taglist(a:id)
  call s:Verbose('%2 -> %1 functions definitions & declarations matching %2 found', len(tags), a:id)

  " # Definitions (f)
  let f_tags = filter(copy(tags), 'v:val.kind == "f"')
  let definitions = map(copy(f_tags), 's:ConvertTag(v:val)')
  call s:Verbose('%2 -> %1 functions definitions found: %3', len(definitions), a:id, lh#list#get(definitions, 'name'))
  " Remove inline definitions
  " -> a definition with an access specifier is an inline definition
  call filter(definitions, '! has_key(v:val, "access")')
  " -> We can also use universal ctags {c++.properties} field option
  call filter(definitions, 'get(v:val, "properties","") =~ "inline"')
  call s:Verbose('%2 -> %1 functions definitions kept (class-inline definitions removed): %3', len(definitions), a:id, lh#list#get(definitions, 'name'))

  " # Declarations (p)
  let p_tags = filter(copy(tags), 'v:val.kind == "p"')
  let declarations = map(copy(p_tags), 's:ConvertTag(v:val)')
  call s:Verbose('%2 -> %1 functions declarations found: %3', len(declarations), a:id, lh#list#get(declarations, 'name'))

  " Remove "= 0"
  if get(options, 'remove_pure', 1)
    call filter(declarations, 'v:val.implementation !~ "pure"')
    call s:Verbose('%2 -> %1 functions declarations kept (pure virtual function removed): %3', len(declarations), a:id, lh#list#get(declarations, 'name'))
  endif
  " Remove destructor
  if get(options, 'remove_destructor', 0)
    call filter(declarations, 'stridx(v:val.name, "~") < 0')
    call s:Verbose('%2 -> %1 functions declarations kept (destructors removed): %3', len(declarations), a:id, lh#list#get(declarations, 'name'))
  endif
  " Remove "= default" & "= delete"
  " -> not present in the signature.
  " -> at best, it may be in the command
  call filter(declarations, 'v:val.cmd !~ "=\\v\\s*(default|delete)"')
  " -> We can also use universal ctags {c++.properties} field option
  call filter(declarations, 'get(v:val, "properties","") !~ "default\\|delete"')
  call s:Verbose('%2 -> %1 functions declarations found and kept (defaulted/deleted function removed): %3', len(declarations), a:id, lh#list#get(declarations, 'name'))

  let result = { 'definitions':definitions, 'declarations': declarations }
  return result
endfunction
" }}}3
"------------------------------------------------------------------------
" Function: lh#cpp#AnalysisLib_Function#SearchUnmatched(fn) {{{3
function! s:CmpSig(lhs, rhs) abort
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

function! lh#cpp#AnalysisLib_Function#_ByNameAndSig(lhs, rhs) abort
  let res = a:lhs.name <  a:rhs.name ? -1
        \ : a:lhs.name == a:rhs.name ? s:CmpSig(lh#list#get(a:lhs.parameters,'type'), lh#list#get(a:rhs.parameters, 'type'))
        \ :                             1
  return res
endfunction

function! s:SearchUnmatched(functions) abort
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
function! lh#cpp#AnalysisLib_Function#SearchAllDeclarations(functions) abort
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
function! s:Type2Regex(type, param) abort
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

function! lh#cpp#AnalysisLib_Function#SignatureToSearchRegex2(signature,className) abort
  call s:Verbose("Sig2regex2(%1, %2)", a:signaturen a:className)
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
    if ns == '::'
      " Class in global namespace
      let ns_re = '\%(::\)\='
    else
      let b = substitute(ns, '[^:]', '', 'g')
      let b = substitute(b, '::', '\\%(', 'g')
      let ns_re = b.substitute(ns, '\<\I\i*\>::', '\0\\)\\=', 'g')
    endif
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
function! lh#cpp#AnalysisLib_Function#SignatureToSearchRegex(signature,className) abort
  call s:Verbose("Sig2regex(signature='%1', class='%2')", a:signature, a:className)
  let g:lh#cpp#AnalysisLib_Function#debug_signature = a:signature
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
  " let impl2search = substitute(impl2search, '\%(\<operator\>\s*\([-+*/=!^%]\s*\)\=\)\@<!=[^,)]\+', '', 'g')
  " virtual, static and explicit -> comment => ignored along with spaces {{{4
  let impl2search = substitute(impl2search,
        \ '\_s*\<\%(virtual\|static\|explicit\)\>\_s*', '', 'g')
  " Extract throw specs {{{4
  " let throw_specs = matchstr(impl2search, '\v\)\s*\zs(throw|noexcept).*$')
  " Trim the variables names {{{4
  " Todo: \(un\)signed \(short\|long\) \(int\|float\|double\)
  "       const, *
  "       First non spaced type + exceptions like: scope\s*::\s*type ,
  "       class<xxx,yyy> (scope or type)
  let impl2search = lh#cpp#AnalysisLib_Function#TrimParametersNames(impl2search)
  " class name {{{4
  let className = a:className . (""!=a:className ? '::' : '')
  let g:className = className
  if className =~ '#::#'
    let ns = matchstr(className, '^.*\ze#::#') . '::'
    if ns == '::'
      " class in global namespace
      let ns_re = '\%(::\)\=\zs'
    else
      let b = substitute(ns, '[^:]', '', 'g')
      let b = substitute(b, '::', '\\%(', 'g')
      let ns_re = b.substitute(ns, '\<\i\i*\>::', '\0\\)\\=', 'g')
    endif
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

  " Reinject throw specs {{{4
  " let impl2search .= ' '.throw_specs
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

" Function: lh#cpp#AnalysisLib_Function#generate_search_regex_from_function_info(info) {{{3
function! lh#cpp#AnalysisLib_Function#generate_search_regex_from_function(info) abort
  call s:Verbose('search regex from %1', a:info)
  let g:lh#cpp#AnalysisLib_Function#debug_info = a:info
  let regex  = ''
  " Scope {{{4
  let has_ns = 0
  let parts = []
  for sc in reverse(copy(get(a:info, 'scope', [])))
    if sc.kind =~? 'namespace'
      let has_ns = 1
      let parts += ['\%('.(sc.name).' :: \)\=']
    else
      let parts += [sc.name . ' :: ']
    endif
  endfor
  if !has_ns
    " class in global namespace
    call insert(parts, '\%( :: \)\=\zs', 0)
  endif
  let classname = join(parts, '')
  let regex .= classname

  " Function name {{{4
  " - protect ~ in destructor name      {{{5
  let name = escape(a:info.name, '~')
  " - '[,' '],' pointers                {{{5
  let name = substitute(name, '\s*\([[\]*]\)\s*', ' \1 ', 'g')
  " - operator*                         {{{5
  let name = substitute(name, 'operator\s*\*', 'operator \\*', '')
  " - <, >, =, (, ), ',' and references {{{5
  let name = substitute(name, '\s*\([-+*/%^=<>!]=\|&&\|||\|[<>=(),&]\)\s*', ' \1 ', 'g')
  " }}}5
  let regex .= name

  " Parameters {{{4
  let regex .= ' ( '
  let params = []
  for p in a:info.parameters
    " TODO: handle C arrays and functions
    let str = substitute(p.type_as_typed, '\s*\([-+*/%^=<>!]=\|&&\|||\|[<>=(),&]\)\s*', ' \1 ', 'g') . ' \%(\<\I\i*\>\)\='
    let params += [str]
  endfor
  let regex .= join(params, ' , ') . ' )'

  " Extra qualifiers {{{4
  let regex .= a:info.const    ? ' const'    : ''
  let regex .= a:info.volatile ? ' volatile' : ''
  let regex .= a:info.ref_qualifier == 'lvalue' ? ' &'
        \  : a:info.ref_qualifier == 'rvalue' ? ' &&'
        \                                     : ''

  let regex .= empty(a:info.noexcept) ? '' : ' '.a:info.noexcept

  " Spaces & comments -> '\(\_s\|/\*.\{-}\*/\|//.*$\)*' and \i {{{4
  let full_regex = substitute(regex, ' ',
        \ '\\%(\\_s\\|/\\*.\\{-}\\*/\\|//.*$\\)*', 'g')
  " Note: \%(\) is like \(\) but the subexpressions are not counted.
  " Note: ' \zs' inserted at the start of the regex helps ignore any comments
  " before the signature of the function.

  " Return {{{4
  let res = {'regex': full_regex, 'simple_re': regex,
        \ 'ispure': a:info.pure, 'isWithoutDefinition': !empty(a:info.special_definition)}
  return res
endfunction
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
function! lh#cpp#AnalysisLib_Function#TrimParametersNames(str) abort
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
  while params !~ '^\s*$'
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
  let res = substitute(head . strpart(params_types,1) . tail, '\s\s\+', ' ', 'g')
  call s:Verbose("param2regex: %1  ---> %2", a:str, res)
  return res
endfunction
" }}}3
"------------------------------------------------------------------------
" }}}2

" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
