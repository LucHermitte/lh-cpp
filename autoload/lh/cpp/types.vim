"=============================================================================
" File:         autoload/lh/cpp/types.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.1.
let s:k_version = '221'
" Created:      15th Dec 2015
" Last Update:  22nd Nov 2020
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

  function! res.is_template() abort
    return self.type =~ '<'
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

call s:RegisterTypes(['ifstream', 'ofstream'], 'std', 'fstream')


" - common types with template parameters {{{4
"   ... defined in the eponym header file
let s:std_types = [
      \ 'array<%1,%2>', 'bitset<%1>', 'complex<%1>', 'deque<%1>',
      \ 'forward_list<%1>', 'function<%1>', 'hash<%1>', 'initializer_list<%1>',
      \ 'list<%1>', 'map<%1,%2>', 'multimap<%1,%2>', 'multiset<%1>',
      \ 'priority_queue<%1>', 'queue<%1>', 'set<%1>', 'span<%1>',
      \ 'stack<%1>', 'tuple<%1>', 'unordered_map<%1>',
      \'unordered_multimap<%1,%2>', 'unordered_multiset<%1>',
      \ 'unordered_set<%1>', 'vector<%1>'
      \]
call s:RegisterTypes(s:std_types, 'std')

" - traits {{{4
let s:std_types = [
      \ 'is_void<%1>', 'is_null_pointer<%1>', 'is_integral<%1>',
      \ 'is_floating_point<%1>', 'is_array<%1>', 'is_enum<%1>',
      \ 'is_union<%1>', 'is_class<%1>', 'is_function<%1>', 'is_pointer<%1>',
      \ 'is_lvalue_reference<%1>', 'is_rvalue_reference<%1>',
      \ 'is_member_object_pointer<%1>', 'is_member_function_pointer<%1>',
      \ 'is_fundamental<%1>', 'is_arithmetic<%1>', 'is_scalar<%1>',
      \ 'is_object<%1>', 'is_compound<%1>', 'is_reference<%1>',
      \ 'is_member_pointer<%1>', 'is_const<%1>', 'is_volatile<%1>',
      \ 'is_trivial<%1>', 'is_trivially_assignable<%1>',
      \ 'is_standard_layout<%1>', 'is_pod<%1>', 'is_literal_type<%1>',
      \ 'has_unique_object_representation<%1>', 'is_empty<%1>',
      \ 'is_polymorphic<%1>', 'is_abstract<%1>', 'is_final<%1>',
      \ 'is_aggregate<%1>', 'is_signed<%1>', 'is_unsigned<%1>',
      \ 'is_bounded_array<%1>', 'is_unbounded_array<%1>', 'is_scoped_enum<%1>',
      \ 'is_constructible<%1>', 'is_trivially_constructible<%1>',
      \ 'is_nothrow_constructible<%1>', 'is_default_constructible<%1>',
      \ 'is_trivially_default_constructible<%1>',
      \ 'is_nothrow_default_constructible<%1>', 'is_copy_constructible<%1>',
      \ 'is_trivially_copy_constructible<%1>',
      \ 'is_nothrow_copy_constructible<%1>', 'is_move_constructible<%1>',
      \ 'is_trivially_move_constructible<%1>',
      \ 'is_nothrow_move_constructible<%1>', 'is_assignable<%1>',
      \ 'is_trivially_assignable<%1>', 'is_nothrow_assignable<%1>',
      \ 'is_default_assignable<%1>', 'is_trivially_default_assignable<%1>',
      \ 'is_nothrow_default_assignable<%1>', 'is_copy_assignable<%1>',
      \ 'is_trivially_copy_assignable<%1>', 'is_nothrow_copy_assignable<%1>',
      \ 'is_move_assignable<%1>', 'is_trivially_move_assignable<%1>',
      \ 'is_nothrow_move_assignable<%1>', 'is_destructible<%1>',
      \ 'is_trivially_destructible<%1>', 'is_nothrow_destructible<%1>',
      \ 'has_virtual_destructor<%1>', 'is_swappable<%1>',
      \ 'is_swappable_with<%1>', 'is_nothrow_swappable<%1>',
      \ 'is_nothrow_swappable_with<%1>', 'is_same<%1>', 'is_baseof<%1>',
      \ 'is_convertible<%1>', 'is_nothrow_convertible<%1>',
      \ 'is_invocable<%1>', 'is_invocable_r<%1>', 'is_nothrow_invocable<%1>',
      \ 'is_nothrow_invocable_r<%1>', 'is_layout_compatible<%1>',
      \ 'is_pointer_inconvertible_base_of<%1>',
      \ 'is_pointer_inconvertible_with_class<%1>',
      \ 'is_corresponding_member<%1>', 'is_constant_evaluated<%1>'
      \]
call s:RegisterTypes(s:std_types, 'std', 'type_traits')
" (Almost) all boolean traits have a constexpr variable in the form _v
" They are not types, but let's store them here for now
call map(s:std_types, 'substitute(v:val, "<", "_v<", "")')
call s:RegisterTypes(s:std_types, 'std', 'type_traits')

call s:RegisterTypes(['void_t'], 'std', 'type_traits')
let s:std_types = [
      \ 'remove_cv<%1>', 'remove_const<%1>', 'remove_volatile<%1>',
      \ 'add_cv<%1>', 'add_const<%1>', 'add_volatile<%1>',
      \ 'remove_reference<%1>', 'add_lvalue_reference<%1>',
      \ 'add_rvalue_reference<%1>', 'remove_pointer<%1>',
      \'add_pointer<%1>', 'make_signed<%1>', 'make_unsigned<%1>',
      \'remove_extent<%1>', 'remove_all_extents<%1>',
      \'aligned_storage<%1>', 'aligned_union<%1>', 'decay<%1>',
      \'remove_cvref<%1>', 'enable_if<%1>', 'conditional<%1>',
      \'common_type<%1>', 'common_reference<%1>',
      \'basic_common_reference<%1>', 'underlying_type<%1>',
      \'result_of<%1>', 'invoke_result<%1>', 'type_identity<%1>'
      \'conjuction<%1>', 'disjunction<%1>', 'negation<%1>',
      \'integral_constant<%1>', 'bool_constant<%1>'
      \]
call s:RegisterTypes(s:std_types, 'std', 'type_traits')
" (Almost) all type traits have a shortcut in the form _t
call map(s:std_types, 'substitute(v:val, "<", "_t<", "")')
call s:RegisterTypes(s:std_types, 'std', 'type_traits')


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

call s:RegisterTypes(['numeric_limits<%1>'], 'std', ['limits'])

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
