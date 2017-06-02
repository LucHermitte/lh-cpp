"=============================================================================
" File:         autoload/lh/cpp/analyse.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      08th Apr 2016
" Last Update:  02nd Jun 2017
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

" Function: lh#cpp#analyse#var_type(name [,default]) {{{3
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
      let cleanup = cleanup
            \.register('call lh#dev#end_tag_session()')
      let tags = lh#dev#start_tag_session()
      let pat = '.*\<'.a:name.'\>.*'
      " FIXME: get the scopename of the current function as well=> ClassName::foobar()
      let classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), 'class')
      let defs = filter(copy(tags), 'v:val.name =~ classname."::".pat || (v:val.name =~ pat && s:GetClassName(v:val) =~ classname)')
      call s:Verbose('Attributes of %1 matching %2: %3', classname, pat, defs)
      let t_vars  = lh#list#copy_if(defs, [], 'v:1_.kind =~ "[lvx]"')
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
  endtry
endfunction

" Function: lh#cpp#analyse#token(name, ...) {{{3
function! lh#cpp#analyse#token(name, ...) abort
  let cleanup = lh#on#exit()
        \.register('call lh#dev#end_tag_session()')
  let tags = lh#dev#start_tag_session()
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
      if lh#tags#ctags_flavour() == 'utags'
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
    call cleanup.finalize()
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
