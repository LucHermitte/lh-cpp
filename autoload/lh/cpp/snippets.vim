"=============================================================================
" File:         autoload/lh/cpp/snippets.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/License.md>
" Version:      2.2.0.
let s:k_version = '220'
" Created:      03rd Nov 2015
" Last Update:  14th Mar 2017
"------------------------------------------------------------------------
" Description:
"       Tool functions to help write snippets (ftplugin/c/c_snippets.vim)
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
function! lh#cpp#snippets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#snippets#verbose(...)
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

function! lh#cpp#snippets#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1
" # snippets functions {{{2

" Function: lh#cpp#snippets#def_abbr(key, expr) {{{3
function! lh#cpp#snippets#def_abbr(key, expr) abort
  if getline('.') =~ '^\s*#'
    return a:key
  endif
  " Default behaviour
  if type(a:expr) == type({})
    " This is a switch
    let exprs = filter(items(a:expr), 'eval(v:val[0])')
    call lh#assert#value(exprs).not().empty("No case found for the mapping ". string(a:key)." --> ".string(a:expr))
    let expr = exprs[0][1]
  else
    let expr = a:expr
  endif
  let rhs = lh#dev#style#apply(expr)
  return lh#map#insert_seq(a:key, rhs)
endfunction

" Function: lh#cpp#snippets#def_map(key, expr1, expr2) {{{3
function! lh#cpp#snippets#def_map(key, expr1, expr2) abort
  if lh#brackets#usemarks()
    return "\<c-r>=lh#map#no_context2('".a:key."',lh#map#build_map_seq('".a:expr2."'))\<cr>"
  else
    return "\<c-r>=lh#map#no_context2('".a:key."', '".a:expr1."')\<cr>"
  endif
endfunction

" Function: lh#cpp#snippets#insert_return() {{{3
function! lh#cpp#snippets#insert_return() abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*$'
    return lh#map#build_map_seq('return ;!mark!\<esc\>==0:call lh#cpp#snippets#_goto_return_semicolon()\<cr\>i')
  else
    let spacesLen = strlen(matchstr(l, '^\s*'))
    let stripCmd = (spacesLen!=0) ? '\<esc\>'.'ct'.l[spacesLen] : ''
    echo stripCmd
    if stridx(l, ';') != -1
      return lh#map#build_map_seq(stripCmd.'return \<esc\>==0:call lh#cpp#snippets#_goto_return_semicolon()\<cr\>a')
    elseif stridx(l, '}') != -1
      return lh#map#build_map_seq(stripCmd.'return ;!mark!\<esc\>==0:call lh#cpp#snippets#_goto_return_semicolon()\<cr\>i')
    else
      return lh#map#build_map_seq(stripCmd.'return \<esc\>==A;')
    endif
  endif
endfunction

" Function: lh#cpp#snippets#insert_if_not_after(key, what, pattern) {{{3
function! lh#cpp#snippets#insert_if_not_after(key, what, pattern) abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, 0, c)
  if l =~ a:pattern.'\s*$'
    return a:key
  else
    return lh#cpp#snippets#def_abbr(a:key, a:what)
  endif
endfunction

" Function: lh#cpp#snippets#insert_if_not_before(key, what, pattern) {{{3
function! lh#cpp#snippets#insert_if_not_before(key, what, pattern) abort
  let c = col('.') - 1
  let l = getline('.')
  let l = strpart(l, c)
  if l =~ '^\s*'.a:pattern
    return a:key
  else
    return lh#cpp#snippets#def_abbr(a:key, a:what)
  endif
endfunction

" Function: lh#cpp#snippets#typedef_typename() {{{3
function! lh#cpp#snippets#typedef_typename() abort
  return lh#cpp#snippets#insert_if_not_after('typename ', 'typedef ', '\S')
endfunction

" Function: lh#cpp#snippets#current_namespace(default) {{{3
function! lh#cpp#snippets#current_namespace(default) abort
  let ns = lh#dev#option#get('project_namespace', &ft, '')
  return empty(ns) ? a:default : (ns.'::')
endfunction

" Function: lh#cpp#snippets#select_expr_4_surrounding() {{{3
function! lh#cpp#snippets#select_expr_4_surrounding() abort
  " Go to the first non blank character of the line
  :normal! ^
  " Search either the first semin-colon or the end of the line.
  :call search(';\|\s*$', 'c')
  " If we are not at the end of the line
  if getline('.')[col('.')-1] =~ ';\|\s'
    " If it is followed by blanck characters
    if strpart(getline('.'), col('.')) =~ '^\s*$'
      " then trim the ';' (or the space) and every thing after
      exe "normal! \"_d$"
    else
      " otherwise replace the ';' by a newline character, and goto the end of
      " the previous line (where the line has been cut)
      exe "normal! \"_s\n\<esc>k$"
    endif
  endif
  " And then select till the first non blank character of the line
  :normal! v^
endfunction

" Function: lh#cpp#snippets#begin_end() {{{3
" In std::foreach and std::find algorithms, ..., expand 'algo(container§)'
" into:
" - 'algo(container.begin(),container.end()§)',
" - 'algo(container.rbegin(),container.rend()§)',
" - 'algo(container.cbegin(),container.cend()§)',
" - 'algo(begin.(container),end.(container)§)',
" - 'algo(rbegin.(container),rend.(container)§)',
" - 'algo(cbegin.(container),cend.(container)§)',
"
" Objectives: support redo/repeat
" Constants {{{4
let s:k_begin_end_fmt = {
      \ 'c++98': '%1.%2()',
      \ 'std': 'std::%2(%1)',
      \ 'boost': 'boost::%2(%1)',
      \ 'adl': '%2(%1)'
      \ }
let s:k_end = {
      \ 'begin'  : 'end',
      \ 'rbegin' : 'rend',
      \ 'cbegin' : 'cend',
      \ 'crbegin': 'crend'
      \ }
let s:k_begin_end_inc = {
      \ 'c++98': [],
      \ 'std': ['<iterator>'],
      \ 'boost': ['<boost/range/begin.hpp>', '<boost/range/end.hpp>'],
      \ 'adl': []
      \ }

function! s:Style() " {{{4
  let style = lh#option#get('cpp_begin_end_style')
  if lh#option#is_unset(style)
    unlet style
    let style
          \ = lh#cpp#use_cpp11() ? 'std'
          \ :                     'c++98'
    " \ : lh#cpp#is_boost_used() ? 'boost'
  endif
  return style
endfunction

function! lh#cpp#snippets#_select_begin_end(cont, function) " {{{4
  let style = s:Style()
  return lh#fmt#printf(s:k_begin_end_fmt[style], a:cont, a:function)
endfunction

" Function: lh#cpp#snippets#_include_begin_end() {{{3
function! lh#cpp#snippets#_include_begin_end() abort
  let style = s:Style()
  " TODO: find a better way to organize options
  return lh#option#get('cpp_begin_end_includes', get(s:k_begin_end_inc, style, []))
endfunction

function! lh#cpp#snippets#_begin_end(begin) abort " {{{4
  let saved_pos = getpos('.')

  let char_c = lh#position#char_at_pos(getpos('.'))
  let accept_at_current = char_c == '(' ? 'c' : ''
  if searchpair('(',',',')','bW'.accept_at_current,'lh#syntax#skip()') == 0
        \ && searchpair('(',',',')','bW','lh#syntax#skip()') == 0
    " Test necessary because 'c' flag and Skip() don't always work well together
    throw "Not on a parameter"
  endif
  " Goto next character
  call search('.')

  let pos = [line('.'), col('.')]
  call setpos('.', saved_pos)

  " let g:saved_pos = saved_pos
  " let g:pos = pos

  if saved_pos[1] == pos[0] && saved_pos[2] == pos[1]
    " No container under the cursor => use placeholders
    let cont = lh#marker#txt('container')
    return lh#cpp#snippets#_select_begin_end(cont, a:begin). ', ' .lh#cpp#snippets#_select_begin_end(cont, s:k_end[a:begin])
  endif

  " Let's suppose same line
  " TODO:
  " - add \s after ",", but not after "(" => use apply style on
  "   - previous.head,
  "   - and ', '.head
  "
  " Extract container name (and leading whitespace) from the two positions
  let cont = lh#position#extract(pos, saved_pos[1:2])

  " Check we aren't selecting too many things
  if pos[0] != saved_pos[1] && cont =~ '{[^}]*$'
    throw "lvalue not in a function call, cannot expand begin/end on it."
  endif

  " Add .begin/.end on "foo(bar)" ?
  if lh#position#char_at(saved_pos[1], saved_pos[2]-1) == ')'
    let choice = lh#ui#which('lh#ui#confirm', 'Do you really want to call begin() *and* end() on a function result?', "&Yes\n&No", 2)
    if choice == 'No'
      return ""
    endif
  endif

  " Number of characters to delete = len - nb of "\n"
  let len = lh#encoding#strlen(cont)
        \ - len(substitute(cont, "[^\n]", '', 'g'))
  " trim trailing spaces, but not those at the start
  let [all, head, cont; rest] = matchlist(cont, '\v^(\_s*)(.{-})\_s*$')
  if pos[1] == 1 && head =~ '^\s\+$'
    " text on a new line => head2 shall induce a new line
    " TODO: support styling option: "\n, " or ",\n"
    let head2 = "\n"
  else
    let head2 = ""
  endif
  if empty(cont)
    " No container under the cursor => use placeholders
    let cont = lh#marker#txt('container')
  endif
  " Build the string to "insert"
  let res = repeat("\<bs>", len)
        \ . head . lh#cpp#snippets#_select_begin_end(cont, a:begin).
        \ ', '.head2 .lh#cpp#snippets#_select_begin_end(cont, s:k_end[a:begin])
  " if pos[0] != saved_pos[1]
    " When <bs> clear characters at the start of the line, it jumps over indent
    " => we force sw to 1
    let sw=shiftwidth()
    set sw=1
    let res .= "\<c-o>:set sw=".sw."\<cr>"
  " endif
  return res
endfunction

" Function: lh#cpp#snippets#_convert_cast(cast_type) {{{3
" TODO: have s:k_cast_fmt be a [bg]:({ft}_) option.
" Beware the following list is duplicated in ftplugin/cpp/cpp_snippets.vim
let s:k_cast = {
      \ 'sc': 'static_cast',
      \ 'dc': 'dynamic_cast',
      \ 'cc': 'const_cast',
      \ 'rc': 'reinterpret_cast',
      \ 'lc': 'boost::lexical_cast'
      \ }
let s:k_cast_fmt = '%1<%2>(%3)'

function! lh#cpp#snippets#_convert_to_cpp_cast(cast_type) abort
  " Extract text to convert
  let c_cast = lh#visual#selection()

  " Strip the possible brackets around the expression
  " matchlist seems to cause an odd error on multiline C cast expressions: it
  " have the fucntion called again.
  let [all, type, expr ; tail] = matchlist(c_cast,  '\v^\(\_s*(.{-})\_s*\)\_s*(.{-})\_s*$')
  let expr = substitute(expr, '\v^\(\s*(.{-})\s*\)$', '\1', '')
  "
  " Build the C++-casting from the C casting
  let new_cast = lh#fmt#printf(s:k_cast_fmt, s:k_cast[a:cast_type], type, expr)
  " let new_cast = a:cast_type.'<'.type.'>('.expr.')'
  " Do the replacement
  silent exe "normal! gvs".new_cast."\<esc>"
endfunction

"------------------------------------------------------------------------
" # Functions for mu-template template-files {{{2

" Function: lh#cpp#snippets#_merge_include_data(name_and_maybe_more, data2) {{{3
function! lh#cpp#snippets#_merge_include_data(name_and_maybe_more, data2) abort
  let data = copy(a:data2)
  if type(a:name_and_maybe_more) == type({})
    " No "name" key => error
    let name = a:name_and_maybe_more.name
    call extend(data, a:name_and_maybe_more)
    call remove(data, 'name')
  else
    let name = a:name_and_maybe_more
  endif
  return {name : data}
endfunction

" Function: lh#cpp#snippets#parents(parents) {{{3
function! lh#cpp#snippets#parents(parents) abort
  let includes = []
  let list = []
  for parent in a:parents
    for [name, data] in items(parent)
      let type_info = lh#cpp#types#get_info(name)
      let list += [
            \  get(data, 'visibility', 'public') . ' '
            \ .(get(data, 'virtual', 0) ? 'virtual ' : '')
            \ .type_info.typename_for_header()
            \ ]
      if has_key(data, 'includes')
        call lh#list#flat_extend(includes, data['includes'])
      endif
      if has_key(type_info, 'includes')
        call extend(includes, type_info.includes)
      endif
    endfor
  endfor
  let res = ''
  if !empty(list)
    let res = len(list) > 1 ? "\n" : " "
    let res .= ': '.join(list, "\n, ")
  endif
  call lh#list#unique_sort(includes)
  return [res, includes]
endfunction

" Function: lh#cpp#snippets#constructor_name(class) {{{3
function! lh#cpp#snippets#constructor_name(class) abort
  " Assert len(values(a:class)) == 1
  let data = split(keys(a:class)[0], '::')
  let data += [data[-1]]
  let res = join(data, '::')
  return res
endfunction

" Function: lh#cpp#snippets#_filter_functions(list, visibility) {{{3
" Function: lh#cpp#snippets#_filter_functions(list, field, value)
function! lh#cpp#snippets#_filter_functions(list, ...) abort
  if a:0 == 1
    let value = a:1
    let field = 'visibility'
    let default = 'public'
  elseif a:0 == 2
    let value = a:2
    let field = a:1
    let default = ''
  else
    call lh#assert#unexpected('Incorrect number of argument in lh#cpp#snippets#_filter_functions -> '.string(a:000))
  endif
  let res = copy(a:list)
  if value == "public"
    call filter(res, 'get(v:val, field, "public") == value && get(v:val, "how", "") != "deleted"')
  elseif value == "protected"
    call filter(res, 'get(v:val, field, "public") == value')
  elseif value == "private"
    call filter(res, 'get(v:val, field, "public") == value || get(v:val, "how", "") == "deleted"')
  else "visi=none, or other fields
    call filter(res, 'get(v:val, field, default) == value')
  endif
  return res
endfunction

" Function: lh#cpp#snippets#nullptr() {{{3
function! lh#cpp#snippets#nullptr(...) abort
  return lh#option#get('cpp_nullptr', lh#cpp#use_cpp11() ? 'nullptr' : '0')
endfunction

" Function: lh#cpp#snippets#noexcept([condition]) {{{3
function! lh#cpp#snippets#noexcept(...) abort
  let noexcept = lh#option#get('cpp_noexcept')
  let args = empty(a:000) ? '' : '('.a:1.')'
  if lh#option#is_set(noexcept)
    return lh#fmt#printf(noexcept, args)
  endif
  if lh#cpp#use_cpp11()
    return 'noexcept'.args
  else
    return 'throw()'
  endif
endfunction

" Function: lh#cpp#snippets#deleted() {{{3
function! lh#cpp#snippets#deleted() abort
  let deleted = lh#option#get('cpp_deleted')
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(deleted)
    return deleted
  endif
  if lh#cpp#use_cpp11()
    return '= delete'
  else
    return '/* = delete */'
  endif
endfunction

" Function: lh#cpp#snippets#override() {{{3
function! lh#cpp#snippets#override() abort
  let override = lh#option#get('cpp_override')
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(override)
    return override
  endif
  if lh#cpp#use_cpp11()
    return 'override'
  else
    return '/* override */'
  endif
endfunction

" Function: lh#cpp#snippets#defaulted() {{{3
function! lh#cpp#snippets#defaulted() abort
  let defaulted = lh#option#get('cpp_defaulted')
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(defaulted)
    return defaulted
  endif
  if lh#cpp#use_cpp11()
    return '= default'
  else
    " Don't know how to default functions in C++98
    return '/* = default */'
  endif
endfunction

" Function: lh#cpp#snippets#pure() {{{3
function! lh#cpp#snippets#pure() abort
  return "= 0"
endfunction

" Function: lh#cpp#snippets#return_ptr_type(type) {{{3
function! lh#cpp#snippets#return_ptr_type(type) abort
  let return_type = lh#option#get('cpp_return_ptr_type')
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(return_type)
    return printf(return_type, a:type)
  endif
  call lh#mut#_add_post_expand_callback('lh#dev#import#add("<memory>")')
  if lh#cpp#use_cpp11()
    return 'std::unique_ptr<'.a:type.'>'
  else
    return 'std::auto_ptr<'.a:type.'>'
  endif
endfunction

" Function: lh#cpp#snippets#make_ptr(type, args) {{{3
function! lh#cpp#snippets#make_ptr(type_dynamic, type_static, args) abort
  let make_ptr = lh#option#get('cpp_make_ptr')
  let args = empty(a:000) ? '' : a:1
  if lh#option#is_set(make_ptr)
    return lh#fmt#printf(make_ptr, a:type_static, a:type_dynamic, a:args)
  else
    unlet make_ptr
  endif
  call lh#mut#_add_post_expand_callback('lh#dev#import#add("<memory>")')
  if lh#cpp#use_cpp14()
    " upcast is implicit with unique_ptr => using only the dynamic type
    let make_ptr = 'std::make_unique(%3)'
  elseif lh#cpp#use_cpp11()
    " upcast is implicit with unique_ptr => using only the dynamic type
    let make_ptr = 'std::unique_ptr<%2>(new %2(%3))'
  else
    let make_ptr = 'std::auto_ptr<%1>(new %2(%3))'
  endif
  return lh#fmt#printf(make_ptr, a:type_static, a:type_dynamic, a:args)
endfunction

" Function: lh#cpp#snippets#requires_destructor(attributes) {{{3
" - T* will require a destructor in current class
" - auto_ptr<> will require a destructor in current class, even an empty (this
"   is because otherwise we can't garanty the deletion function called is the
"   right one)
" - unique_ptr<>, doesn't require anything
" - Let's suppose other types to follow RAII => don't need
" - still an option in case code is not idiomatic and destructors may be needed
function! lh#cpp#snippets#requires_destructor(attributes) abort
  return lh#list#find_if(a:attributes, 'lh#cpp#snippets#_this_param_requires_a_destructor(v:val)') >= 0
endfunction

" Function: lh#cpp#snippets#requires_copy_operations(attributes) {{{3
" - pointer, references, uncopyable types (stream, mutex, lock, entities, ...) => yes
function! lh#cpp#snippets#requires_copy_operations(attributes) abort
  return lh#list#find_if(a:attributes, 'lh#cpp#snippets#_this_param_requires_copy_operations(v:val)') >= 0
endfunction

" Function: lh#cpp#snippets#shall_explicit_defaults() {{{3
function! lh#cpp#snippets#shall_explicit_defaults() abort
  return lh#cpp#use_cpp11() && lh#option#get("cpp_explicit_default", 0)
endfunction

" Function: lh#cpp#snippets#build_param_list(parameters) {{{3
" Fields:
" - name
" - type
" - default
" - nl (bool)
function! lh#cpp#snippets#build_param_list(parameters) abort
  " 1- Handle default params, if any. {{{4
  let l:ShowDefaultParams       = lh#dev#option#get('ShowDefaultParams', &ft, 1)
  "    0 -> ""              : ignored
  "    1 -> "/* = value */" : commented
  "    2 -> "/*=value*/"    : commented, spaces trimmed
  "    3 -> "/*value*/"     : commented, spaces trimmed, no equal sign
  if     l:ShowDefaultParams == 0 | let pattern = ''
  elseif l:ShowDefaultParams == 1 | let pattern = '/* = \1 */'
  elseif l:ShowDefaultParams == 2 | let pattern = '/*=\1*/'
  elseif l:ShowDefaultParams == 3 | let pattern = '/*\1*/'
  else                            | let pattern = ''
  endif

  " 2- Build the string to return {{{4
  let implParams = []
  for param in a:parameters
    let sParam = (get(param, 'nl', '0') ? "\n" : '')
          \ . get(param, 'type', lh#marker#txt('type')) . ' ' . lh#dev#naming#param(param.name)

    if has_key(param, 'default')
      let sParam .= substitute(param.default, '\v(.+)', pattern, '')
    endif
    " echo "param=".param
    call add(implParams, sParam)
  endfor
  let implParamsStr = join(implParams, ', ')
  return implParamsStr
endfunction

" Function: lh#cpp#snippets#duplicate_param(param) {{{3
function! lh#cpp#snippets#duplicate_param(param, type) abort
  if  lh#cpp#snippets#_this_param_requires_copy_operations(a:type)
    return lh#fmt#printf(lh#marker#txt('duplicate(%1)'), a:param)
  else
    return a:param
  endif
endfunction

" # Functions to tune mu-template class skeleton {{{2

" Function: lh#cpp#snippets#new_function_list() {{{3
function! s:public()      dict abort " {{{4
  return lh#cpp#snippets#_filter_functions(self.list, "public")
endfunction
function! s:protected()   dict abort " {{{4
  return lh#cpp#snippets#_filter_functions(self.list, "protected")
endfunction
function! s:private()     dict abort " {{{4
  return lh#cpp#snippets#_filter_functions(self.list, "private")
endfunction
function! s:add(fns)      dict abort " {{{4
  let self.list += a:fns
  for fn in a:fns
    call extend(fn, {'add_new': function(s:getSNR('AddNew'))})
  endfor
  return self
endfunction
function! s:insert(fn)    dict abort " {{{4
  call extend(a:fn, {'add_new': function(s:getSNR('AddNew'))})
  call insert(self.list, a:fn)
  return self
endfunction
function! s:get(id)       dict abort " {{{4
  if type(a:id) == type('name')
    let res = filter(copy(self.list), 'has_key(v:val, "name") && v:val.name =~ a:id')
  else
    let res = filter(copy(self.list), 's:FunctionMatchesDescription(v:val, a:id)')
  endif
  return res
endfunction
function! s:get1(id, ...) dict abort " {{{4
  let matching_functions = self.get(a:id)
  if len(matching_functions) > 1
    throw "lh-cpp: Too many functions match ".string(a:id)
  elseif empty(matching_functions)
    " New reference created, and returned
    let new_fn = a:0 > 0 ? a:1 : {}
    " Force the searched pattern onto the function to return, at least this,
    " is correct
    call extend(new_fn, a:id)
    call self.add([new_fn])
    return new_fn
  endif
endfunction
function! s:filter(descr) dict abort " {{{4
  let res = filter(copy(self.list), 's:FunctionMatchesDescription(v:val, a:descr)')
  return res
endfunction
function! s:reverse()     dict abort "{{{4
  return reverse(self.list)
endfunction
function! lh#cpp#snippets#new_function_list() abort " {{{4
  let fl = lh#object#make_top_type({ 'list': []})
  let fl.public    = function(s:getSNR('public'))
  let fl.protected = function(s:getSNR('protected'))
  let fl.private   = function(s:getSNR('private'))
  let fl.add       = function(s:getSNR('add'))
  let fl.insert    = function(s:getSNR('insert'))
  let fl.get       = function(s:getSNR('get'))
  let fl.get1      = function(s:getSNR('get1'))
  let fl.filter    = function(s:getSNR('filter'))
  let fl.reverse   = function(s:getSNR('reverse'))

  " Return object {{{4
  return fl
" }}}4
endfunction

function! s:AddNew(dst) dict abort
  return extend(self, a:dst, 'keep')
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Misc {{{2
" s:getSNR([func_name]) {{{3
function! s:getSNR(...)
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
endfunction

" Function: s:FunctionMatchesDescription(fn, descr) {{{3
function! s:FunctionMatchesDescription(fn, descr)
  for [k, v] in items(a:descr)
    if ! has_key(a:fn, k) || a:fn[k] != v
      return 0
    endif
    return 1
  endfor
endfunction

" Function: lh#cpp#snippets#_this_param_requires_a_destructor(attribute) {{{3
" see lh#cpp#snippets#requires_destructor(attributes)
function! lh#cpp#snippets#_this_param_requires_a_destructor(attribute) abort
  if !lh#dev#cpp#types#IsPointer(a:attribute.type)
    " TODO: We may need another option as well. Or a list of types ?
    return 0
  elseif a:attribute.type =~ '\vauto_ptr|[*]'
    return 1
  elseif a:attribute.type =~ '\v^[a-z0-9]*_ptr|non_null'
    " let's suppose scoped_ptr, unique_ptr, ...
    " "*_ptr" follows standard naming style, we can expect this is not an
    " unsafe pointer type
    return 0
  elseif lh#option#get('cpp_always_a_destructor_when_there_is_a_pointer_attribute', 0)
    return 1
  else
    return 0
  endif
endfunction

" Function: lh#cpp#snippets#_this_param_requires_copy_operations(attribute) {{{3
function! lh#cpp#snippets#_this_param_requires_copy_operations(attribute) abort
  let type = type(a:attribute) == type({}) ? a:attribute.type : a:attribute

  if lh#dev#cpp#types#is_not_owning_ptr(type)
    return 0
  elseif lh#dev#cpp#types#IsPointer(type)
    return 1
  else
    " TODO: recognize non publicy copyable types
    return 0
  endif
endfunction

" Function: lh#cpp#snippets#_decode_selected_attributes(text) {{{3
" TODO: ask which ones shall be used:
" - in init-ctr param list
" - to generate setters and/or getter
function! lh#cpp#snippets#_decode_selected_attributes(text) abort
  let res = []
  for attr in split(a:text, "\n")
    let attr = matchstr(attr, '^\s*\zs.\{-}\ze;*\s*$')
    let attr_data = lh#dev#option#call('function#_analyse_parameter', &ft, attr, 1)
    let attr_data.name = lh#dev#naming#param(attr_data.name)
    let res += [ attr_data ]
  endfor
  return res
endfunction

" # snippet functions {{{2
" Function: lh#cpp#snippets#_goto_return_semicolon() {{{3
function! lh#cpp#snippets#_goto_return_semicolon() abort
  let p = getpos('.')
  let r = search('return.*;', 'e')
  if r == 0 | call setpos('.', p) | endif
endfunction

" Function: lh#cpp#snippets#_has_a_non_copyable_parent(parents) {{{3
" I'll just test is there is a public parent. From there, let's suppose public
" base classes are noncopyable.
" I'll trust the end-user to have objects from hierarchies to respect
" entity-semantics and be noncopyable (or possibly clonable)
" NB: I should may be test for a private inheritance to a "\cNon_*Copyable"
" class.
function! lh#cpp#snippets#_has_a_non_copyable_parent(parents) abort
  let public_parents = filter(copy(a:parents), 'get(v:val, "visibility", "public") == "public"')
  let res = ! empty(public_parents)
  return res
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
