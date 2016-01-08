"=============================================================================
" File:         autoload/lh/cpp/types.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      15th Dec 2015
" Last Update:  15th Dec 2015
"------------------------------------------------------------------------
" Description:
"       C++ types database
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
function! lh#cpp#types#version()
  return s:k_version
endfunction

" # Debug   {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif
function! lh#cpp#types#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#cpp#types#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Types DB {{{1
" TODO: support: several entries behind a same name -> boost::shared_ptr,
" std::shared_ptr
" # Fetch information

" Function: lh#cpp#types#get_info(type [, default-value]) {{{3
" TODO: support also std::vector
function! lh#cpp#types#get_info(type, ...) abort
  let res = get(s:types, a:type, a:0 ? a:1 : {"type" : a:type, "name" : a:type, 'unknown':1})

  function! res.typename_for_header(...) abort
    let type = []
    if has_key(self, 'namespace') && !empty(self.namespace)
      let type += [self.namespace]
    endif
    " In case there isn't enough
    let nb = max(lh#string#matches(self.type, '\v\%\zs\d+'))
    let args = a:000 + map(range(len(a:000)+1, nb), 'lh#marker#txt("T".v:val)')
    let type += [call('lh#fmt#printf', [self.type] + args)]
    return join(type, '::')
  endfunction
  return res
endfunction

" Function: lh#cpp#types#get_includes(type) {{{3
function! lh#cpp#types#get_includes(type) abort
  let info = get(s:types, a:type, {'includes': []})
  return info.includes
endfunction

" # Filling functions {{{2

function! s:PrepareHeaders(includes, name) " {{{3
  return map(lh#list#flatten([a:includes]), 'lh#fmt#printf("<".v:val.">", a:name)')
endfunction

function! s:ExtractName(type) " {{{3
  return substitute(a:type, '\v\<.*', '', '')
endfunction

function! s:RegisterTypes(list, namespace, ...) " {{{3
  let types = map(copy(a:list), '{"name": s:ExtractName(v:val), "namespace": a:namespace, "type": v:val}')
  if a:0 > 0
    call map(types, 'extend(v:val, {"includes": s:PrepareHeaders(a:1, v:val.name)})')
  else
    call map(types, 'extend(v:val, {"includes": ["<".v:val["name"].">"]})')
  endif

  call map(types, '{(v:val["name"]) : v:val}')
  for type in types
    call extend(s:types, type)
  endfor
endfunction

" # Fill the DB {{{2
let s:types = {}

" * Standard types {{{3
" - types with no template parameters {{{4
let s:std_types = ['fstream', 'string', 'stringstring', 'istream', 'ostream', 'regex', 'thread', 'mutex', 'shared_mutex', 'condition_variable', 'future', 'exception']
call s:RegisterTypes(s:std_types, 'std')


" - types with template parameters {{{4
let s:std_types = [
      \ 'array<%1,%2>', 'bitset<%1>', 'complex<%1>', 'deque<%1>',
      \ 'forward_list<%1>', 'function<%1>', 'hash<%1>', 'initializer_list<%1>',
      \ 'list<%1>', 'map<%1,%2>', 'multimap<%1,%2>', 'multiset<%1>',
      \ 'priority_queue<%1>', 'queue<%1>', 'set<%1>', 'stack<%1>', 'tuple<%1>',
      \ 'unordered_map<%1>', 'unordered_multimap<%1,%2>',
      \ 'unordered_multiset<%1>', 'unordered_set<%1>', 'vector<%1>'
      \]
call s:RegisterTypes(s:std_types, 'std')

" - types defined elsewhere {{{4
let s:std_types = [
      \ 'runtime_error', 'logic_error', 'domain_error', 'out_of_range',
      \ 'future_error', 'invalid_argument', 'range_error', 'overflow_error',
      \ 'underflow_error', 'regex_error', 'system_error', 'bad_cast',
      \ 'bad_alloc', 'bad_typeid', 'bad_weak_ptr', 'bad_function_call',
      \ 'bad_array_new_length', 'bad_exception'
      \]
call s:RegisterTypes(s:std_types, 'std', 'stdexcept')

let s:std_types = [
      \ 'timed_mutex', 'recursive_mutex', 'recursive_timed_mutex', 'lock_guard',
      \ 'unique_lock', 'shared_lock'
      \]
call s:RegisterTypes(s:std_types, 'std', 'mutex')

call s:RegisterTypes(['shared_timed_mutex'], 'std', 'shared_mutex')
call s:RegisterTypes(['condition_variable_any'], 'std', 'condition_variable')
call s:RegisterTypes(['promise', 'packaged_task', 'shared_future'], 'std', 'future')
call s:RegisterTypes(['pair'], 'std', 'utility')
call s:RegisterTypes(['chrono::time_point<%1>', 'chrono::duration<%1>'], 'std', 'chrono')
call s:RegisterTypes(['nullptr_t'], 'std', 'cstddef')
call s:RegisterTypes(['hash<%1>'], 'std', 'functional')

call s:RegisterTypes(['size_t'], 'std',['cstddef', 'cstdio', 'cstring', 'ctime', 'cstdlib', 'cwchar'])
" call s:RegisterTypes(['size_t'], '',['stddef.h', 'stdio.', 'string.h', 'time.h', 'wchar.h'])

" * Boost types {{{3
" - types defined in header file w/ same name {{{4
let s:boost_types = ['noncopyable'
      \]
call s:RegisterTypes(s:boost_types, 'boost', 'boost/%1.hpp')

" - types defined elsewhere {{{4
let s:boost_types = [
      \ 'ptr_array<%1>', 'ptr_deque<%1>', 'ptr_list>%1>', 'ptr_map<%1,2>',
      \ 'ptr_multi_set<%1>', 'ptr_multimap<%1,2>', 'ptr_set<%1>',
      \ 'ptr_vector<%1>'
      \]
call s:RegisterTypes(s:boost_types, 'boost', ['boost/ptr_container.hpp', 'boost/ptr_container/%1.hpp'])
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
