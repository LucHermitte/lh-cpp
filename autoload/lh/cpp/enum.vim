"=============================================================================
" File:         autoload/lh/cpp/enum.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
let s:k_version = 220
" Version:      2.2.0
" Created:      06th Jan 2011
" Last Update:  06th Dec 2016
"------------------------------------------------------------------------
" Description:
"       Support autoload-plugin for :SwitchEnum.
"
"------------------------------------------------------------------------
" Requirements:
"       Requires Vim7+, lh-dev, lh-vim-lib
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#enum#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#enum#verbose(...)
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

function! lh#cpp#enum#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#cpp#enum#expand_enum_to_switch() {{{3
function! lh#cpp#enum#expand_enum_to_switch() abort
  let enum_name = GetCurrentKeyword()
  let def = lh#cpp#enum#get_definition(enum_name)
  let ns  = lh#cpp#AnalysisLib_Class#available_namespaces(line('.'))
  let values = []
  for enum in def.values
    let simplified = map(copy(ns), 'substitute(enum, "^".v:val."::", "", "")')
    let shortest = lh#list#arg_min(ns, function('len'))
    call lh#assert#true(shortest >= 0 && shortest < len(simplified))
    let values += [simplified[shortest]]
  endfor
  let def.values = lh#list#unique_sort(values)
  " TODO: recognize whether this is a type or surround it with markers
  let def.expr = def.name
  call s:Verbose('Generate swith from enum %1 -> %2', enum_name, def)
  if !empty(def)
    normal! diw
    call MuTemplate('c/switch', def)
    " todo: delete enum_name if MuTemplate() expands
  endif
endfunction

" Function: lh#cpp#enum#analyse_token(name, ...) {{{3
function! lh#cpp#enum_analyse#token(name, ...) abort
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
      let t_enums = lh#list#copy_if(defs, [], 'v:1_.kind == "g"')
      let t_vars  = lh#list#copy_if(defs, [], 'v:1_.kind =~ "[lvx]"')
      " nominal case: one type
      if len(t_enums) > 1
        let t_enums = lh#dev#tags#keep_full_names(t_enums)
      endif
      if len(t_vars) > 1
        let t_vars = lh#dev#tags#keep_full_names(t_vars)
      endif
      if len(t_enums) == 1 && empty(t_vars)
        let res = (a:0 > 0) ? (a:1) : {}
        let res['type'] = t_enums[0]
        return res
      elseif len(t_vars) == 1 && empty(t_enums)
        let res = { 'var': t_vars[0] }
        if a:0 > 0
          throw "Variable ".string(a:1)." referencing another variable: ".string(res)
        endif
      elseif !empty(t_enums) && !empty(t_vars)
        throw "Too many compatible identifiers match the alleged ".(a:name)." enum"
      elseif empty(t_enums) && empty(t_vars)
        "No compatible identifier match the alleged enum
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
          let res = lh#cpp#enum#analyse_token(type, res)
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

" Function: lh#cpp#enum#get_definition(name) {{{2
function! lh#cpp#enum#get_definition(name)
  let what = lh#cpp#enum#analyse_token(a:name)
  if empty(what)
    throw "Cannot obtain information on the alleged ".(a:name)." enum"
  endif
  " A- case when the enum follows lh-cpp enum pattern:
  " struct MyEnum {
  "     enum type { E1, E2, ...., MAX__ };
  " };
  if what.type.name =~ "::type$"
    " 1- ask ctags
    " TODO: check weither the else case is enough
    if has_key(what.type, 'struct')
      let super = what.type.struct
    elseif has_key(what.type, 'class')
      let super = what.type.class
    else
      ... ?
    endif
    let enum_values = taglist(super)
    call filter(enum_values, 'get(v:val, "kind", "") == "e"')
  else
    " Other cases, with no guaranties
    if has_key(what.type, 'struct')
      let super = what.type.struct
    elseif has_key(what.type, 'class')
      let super = what.type.class
    else
      let super = '.'
    endif
    let enum_values = taglist(super)
    let enum_name = matchstr(what.type.name, '\(.*::\)\=\zs.*')
    call filter(enum_values, 'get(v:val, "kind", "") == "e" && get(v:val, "enum", "")=~ enum_name')
  endif

  let res = {'type': what.type.name, 'name': (a:name)}
  let enum_values = lh#dev#tags#keep_full_names(enum_values)
  let res['values'] =  lh#list#get(enum_values, 'name')
  return res
endfunction

" Function: lh#cpp#enum#_new(...) {{{2
function! lh#cpp#enum#_new(...)
  try
    " Inhibits the jump part in lh#mut#expand_and_jump()
    let cleanup = lh#on#exit()
          \.restore_option('mt_jump_to_first_markers')
          \.restore('b:cpp_last_enum')
    let b:mt_jump_to_first_markers = 0

    " What is the current scope ?
    let scope = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), 'any')
    if !empty(scope) | let scope .= '::' | endif
    " Insert the enum definition
    let last_line = call('lh#mut#expand_and_jump', [0, 'cpp/enum2']+a:000)
    let last_enum = b:cpp_last_enum
    call append(last_line, '')
    call cursor(last_line+1, 1)
    " Goto to its associated definition file
    call lh#cpp#GotoFunctionImpl#open_cpp_file('')
    " And insert the non-inlined function definitions
    call call('lh#mut#expand_and_jump', [0, 'cpp/enum2-impl', last_enum])
  finally
    " Restores mt_jump_to_first_markers
    call cleanup.finalize()
  endtry

endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
