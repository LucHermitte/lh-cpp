"=============================================================================
" File:         autoload/lh/cpp/analyse.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      08th Apr 2016
" Last Update:  10th Jul 2023
"------------------------------------------------------------------------
" Description:
"       Various functions to analyse C and C++ codes
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#analyse#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#analyse#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#cpp#analyse#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Decode information from vim-clang {{{2
" s:re_noexcept_spec is from autoload/lh/cpp/AnalysisLib_Function.vim
let s:re_noexcept_spec              = '\<noexcept\>\%((\zs.*\ze)\)\='

function! s:decode_function(py_info) abort " {{{3
  let [sNoexceptSpec, idx_s, idx_e] = lh#string#matchstrpos(a:py_info.type.spelling, s:re_noexcept_spec)
  call s:Verbose("sNoexceptSpec: %1 ∈ [%2, %3]", sNoexceptSpec, idx_s, idx_e)

  let info = {}
  let info.is_function   = 1
  let info.kind          = a:py_info.true_kind
  let info.qualifier
        \ = a:py_info.static   ? 'static'
        \ : a:py_info.virtual  ? 'virtual'
        \ : a:py_info.explicit ? 'explicit'
        \ : ''
  let info.return        = a:py_info.true_kind =~ '\vCONSTRUCTOR|DESTRUCTOR'
        \ ? ''
        \ : a:py_info.result_type.spelling
  " let info.constexpr     = s:k_not_available
  let info.const         = a:py_info.const
  let info.volatile      = a:py_info.type.spelling =~ '\v<volatile>'
  let info.pure          = a:py_info.pure
  let info.special_definition
        \ = a:py_info.is_defaulted ? '= default'
        \ : a:py_info.is_deleted   ? '= delete'
        \ : ''
  let info.throw          = [] " Let's forget about this
  let info.noexcept       = sNoexceptSpec
  let info.final          = a:py_info.final
  let info.overriden      = a:py_info.override
  let info.signature      = a:py_info.type.spelling
  let info.fullsignature  = substitute(info.signature, '(', a:py_info.spelling .'(', '')
  let info.parameters     = []
  " TODO: analyse get_tokens() to be more precise
  let last_line = -1
  for py_param in a:py_info.parameters
    let param = {
          \ 'name'   : py_param.spelling
          \,'type'   : py_param.type.spelling
          \,'nl'     : last_line >= 0 && last_line != py_param.extent.start.lnum
          \ }
    " \,'default': s:k_not_available
    let info.parameters += [param]
    let last_line = py_param.extent.end.lnum
  endfor
  let info.special_func
        \ = a:py_info.true_kind == 'CursorKind.CONSTRUCTOR' ? a:py_info.constructor_kind . (empty(a:py_info.constructor_kind)?'':' ').'constructor'
        \ : a:py_info.true_kind == 'CursorKind.DESTRUCTOR' ? 'destructor'
        \ : a:py_info.spelling == 'operator='
        \   ? (info.parameters[0].type =~ 'const' ? 'copy-assignment operator'
        \     :info.parameters[0].type =~ '&&' ? 'move-assignment operator'
        \     :                                  'assignment operator'
        \ )
        \ : ''
  return info
endfunction

" Function: lh#cpp#analyse#get_info([what]) {{{3
function! lh#cpp#analyse#get_info(...) abort
  if lh#has#plugin('autoload/clang.vim') && clang#can_plugin_be_used()
    let py_info = call('clang#get_symbol', a:000)

    if ! py_info
      return lh#option#unset("Sorry vim-clang cannot be used on this signature")
    endif

    let info = {}
    let info.is_function   = 0
    let info.is_class      = 0
    let info.is_namespace  = 0
    let info.kind          = py_info.kind
    let info.name          = py_info.spelling
    " TODO: Some outer scopes may be template classes actually
    let info.scope         = py_info.scope

    " ----< decode tparams
    " TODO: analyse get_tokens() to be more precise
    let info.tparams       = []
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
    " ----< decode extent
    " TODO: analyse get_tokens() to know whether there is a new line after
    " template<....>, the type, the func name...
    let info.start = py_info.extent.start
    let info.end   = py_info.extent.end

    " ----< decode specific kinds (function, class...)
    if py_info.kind =~ '\vFUNCTION|METHOD|CONSTRUCTOR|DESTRUCTOR'
      call extend(info, s:decode_function(py_info), 'force')
    elseif py_info.kind =~ '\vCLASS|STRUCT|UNION'
      let info.is_class = 1
    elseif py_info.kind =~ '\vNAMESPACE'
      let info.is_namespace = 1
    endif
    return info
  else
    return lh#option#unset("Sorry vim-clang cannot be used")
  endif
endfunction

" Function: lh#cpp#analyse#var_type(name [,default]) {{{2
function! lh#cpp#analyse#var_type(name,...) abort
  try
    let p = getpos('.')
    let cleanup = lh#on#exit()
          \.register('call setpos(".",'.string(p).')')
    if a:name =~ '^\s*$'
      return call('s:NoDecl', [a:name]+a:000)
    endif
    if searchdecl(a:name) == 0
      " First: let Vim find the variable definitions
      let def_line = getline('.')
      call s:Verbose('Definition of %1 found line %2: %3', a:name, line('.'), def_line)
    else
      " Then: search in the tags DB (it may be an attribute from the current
      " class)
      let session    = lh#tags#session#get()
      let [var_kind] = session.indexer.get_kind_flags(&ft, ['variable', 'v', 'l'])
      let tags       = session.tags
      let pat = '.*\<'.a:name.'\>.*'
      " FIXME: get the scopename of the current function as well=> ClassName::foobar()
      let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), 'class')
      let defs = filter(copy(tags), 'v:val.name =~ classname."::".pat || (v:val.name =~ pat && s:GetClassName(v:val) =~ classname)')
      call s:Verbose('Attributes of %1 matching %2: %3', classname, pat, defs)
      let t_vars  = filter(copy(defs), 'index(var_kind,  v:val.kind)>=0')
      if empty(t_vars)
        return call('s:NoDecl', [a:name]+a:000)
      elseif len(t_vars) == 1
        let def_line = t_vars[0].cmd
      else
        throw "Too many matching variables"
      endif
    endif
    let def_line = substitute(def_line, '\s*;\s*$\|\s*=.*', '', '')
    let def_line = substitute(def_line, '^\s*', '', '')
    let def = split(def_line, ',') " split function lists
    call filter(def, 'v:val =~ "\\<".a:name."\\s*$"')
    let var = lh#dev#option#call('function#_analyse_parameter', &ft, def[0])
    return var.type
  finally
    call cleanup.finalize()
    if exists('session')
      call session.finalize()
    endif
  endtry
endfunction

" Function: lh#cpp#analyse#token(name, ...) {{{2
" TODO: finish
function! lh#cpp#analyse#token(name, ...) abort
  let session    = lh#tags#session#get()
  let tags       = session.tags
  let type_kinds = session.indexer.get_kind_flags('cpp', 'classes\|structure names\|enumeration names\|typedefs')
  try
    " 1- check whether its a variable or a type
    " 1.1- ask clang, if available
    " 1.2- ask ctags, if available
    " todo? filter on the exact name as well ?
    let pat = '.*\<'.a:name.'\>.*'
    " let defs = taglist(pat)
    let defs = filter(copy(tags), 'v:val.name =~ pat')
    if !empty(defs)
      let t_types = lh#list#copy_if(defs, [], 'v:1_.kind == "g"')
      let var_kinds = 'lvx'
      if lh#tags#ctags_flavour() =~ 'utags'
        let var_kinds .= 'z' " parameters
      endif
      let t_vars  = lh#list#copy_if(defs, [], 'v:1_.kind =~ "['.var_kinds.']"')
      " nominal case: one type
      if len(t_types) > 1
        let t_types = lh#dev#tags#keep_full_names(t_types)
      endif
      if len(t_vars) > 1
        let t_vars = lh#dev#tags#keep_full_names(t_vars)
      endif
      if len(t_types) == 1 && empty(t_vars)
        let res = (a:0 > 0) ? (a:1) : {}
        let res['type'] = t_types[0]
        return res
      elseif len(t_vars) == 1 && empty(t_types)
        let res = { 'var': t_vars[0] }
        if a:0 > 0
          throw "Variable ".string(a:1)." referencing another variable: ".string(res)
        endif
      elseif !empty(t_types) && !empty(t_vars)
        throw "Too many compatible identifiers match the alleged ".(a:name)." symbol"
      elseif empty(t_types) && empty(t_vars)
        "No compatible identifier match the alleged symbol
        "but it can be something to search with searchdecl
        let res = {}
      else
        throw "unexpected case"
      endif
    else
      let res = {}
    endif

    " 1.3- or searchdecl otherwise
    if empty(res)
      let pos = getpos('.')
      try
        let not_found = searchdecl(a:name, 1)
        if not_found | return {} | endif
        " Type or variable ?
        let line = getline('.')
        if line =~ 'enum\s\+\(class\s\+\)\='.(a:name)
          " type
          let res = (a:0 > 0) ? (a:1) : {}
          let res['type'] = {'pos':getpos('.'), 'name': (a:name)}
          return res
        else
          " variable!
          " todo: factorize this common pattern
          let s:re_qualified_name1 = '\%(::\s*\)\=\<\I\i*\>'
          let s:re_qualified_name2 = '\s*::\s*\<\I\i*\>'
          let s:re_qualified_name  = s:re_qualified_name1.'\%('.s:re_qualified_name2.'\)*'
          " let type = matchstr(line, '.*[(),{};]\s\*\<.*\>\ze\s\+'.a:name)
          let type = matchstr(line, s:re_qualified_name.'\ze\s\+'.a:name)
          if type =~ '^\s*$'
            throw "Cannot find an enum type related to the ".a:name." variable defined line ".line('.')
          endif
          let res = { 'var': {'name': (a:name), 'pos':getpos('.')}, 'type': {'name': type}}
          if a:0 > 0
            throw "Variable ".string(a:1)." referencing another variable: ".string(res)
          endif
          let res = lh#cpp#analyse#token(type, res)
          return res
        endif
      finally
        call setpos('.', pos)
      endtry
    endif

    " 2- find the type definition
  finally
    call session.finalize()
  endtry
endfunction

" ## Internal functions {{{1

" Function: s:NoDecl(name, [default]) {{{3
function! s:NoDecl(name, ...) abort
  if a:0 == 0
    throw "Cannot find variable <".a:name."> declaration. Impossible to deduce its type."
  else
    return a:1
  endif
endfunction

" Function: s:GetClassName(dict) {{{3
function! s:GetClassName(dict) abort
  return get(a:dict, "class", get(a:dict, "struct", ""))
endfunction

" Function: lh#cpp#analyse#context([line]) {{{3
" https://vi.stackexchange.com/a/11942/626
function! lh#cpp#analyse#context(...) abort
  let line = get(a:, 1, line('.'))
  let fn = lh#dev#find_function_boundaries(line)
  if fn.lines[0] <= line && line <= fn.lines[1]
    " This is a function
    call lh#assert#value(fn).has_key('fn')
    let kinds = filter(['struct', 'class', 'namespace'], 'has_key(fn.fn, v:val)')
    call lh#assert#value(kinds).not().empty()
    let scope = join(
          \ [ get({'public': '+', 'private': '-', 'protected': '#'}, get(fn.fn, 'access', ''), '')
          \ , substitute(get(fn.fn, 'typeref', ''), '^typename:', '', '')
          \ , fn.fn[kinds[0]] . '::' . fn.fn.name . get(fn.fn, 'signature')
          \ ], ' ')
  else
    " classes, structs, namespaces, ...
    " TODO: don't move the cursor
    let scope = lh#cpp#AnalysisLib_Class#CurrentScope(line, 'any')
  endif
  return scope
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
