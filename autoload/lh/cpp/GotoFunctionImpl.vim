"=============================================================================
" File:         autoload/lh/cpp/GotoFunctionImpl.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/lh-cpp>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/lh-cpp/tree/master/License.md>
" Version:      2.3.0
let s:k_version = '230'
" Created:      07th Oct 2006
" Last Update:  10th Mar 2021
"------------------------------------------------------------------------
" Description:
"       Implementation functions for ftplugin/cpp/cpp_GotoImpl
"
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/cpp/
"       Use Vim 7+
" History:
"       12th Sep 2007:
"       (*) Accepts spaces between "~" and class name (destructors)
"       v1.0.0:
"       (*) Code moved from ftplugin/cpp/cpp_GotoFunctionImpl.vim
"       (*) Fixes issues with g:alternateSearchPath in order to open the .cpp
"       in the correct subdirectory
"       (*) Don't escape '&' (from parameter's type) to build search regex
"       (*) Preserve line breaks between parameters
"       (*) A message is displayed if the position of the function definition
"           cannot be found.
"       v1.1.0
"       (*) two functions moved to autoload/lh/cpp/AnalysisLib_Function
"       v1.1.1
"       (*) Support jump to existing destructor
"       (*) Support jump to constructor with a initialization-list
"       (*) Support "using namespace"
"       (*) Don't expect the searched regex to start the line (as the return
"           type may need to be fully-qualified is the function definition)
"       v2.0.0
"       (*) GPLv3 with exception
"       (*) parameter for the new implementation file extention
"       (*) reuse a know buffer if it already exists -- i.e.: not limited to
"           readable files
"       (*) facultative option: extension of the file where to put the
"           definition of the function.
"       (*) Fix :GOTOIMPL to work even if &isk contains ":"
"       (*) Fix :GOTOIMPL to support operators like +=
"       v2.2.0
"       (*) Use new alternate-lite API to determine the destination file
"       (*) Update options to support specialization
"       (*) Fix extra space introduced by `:MOVETOIMPL`
"       (*) Update to new lh-tags v3.0 and lh-dev new API
"       v2.2.1
"       (*) override and final cannot be used outside class definition
"       v2.3.0
"       (*) Use vim-clang to implement `:GOTOIMPL` -> support
"           templates, and all other C++ constructs
" TODO:
"       (*) add knowledge about C99/C++11 new numeric types
"       (*) :MOVETOIMPL should not expect the open-brace "{" to be of the same
"           line as the function signature.
"       (*) Check how to convert the return, and the parameters, types to their
"           fully-qualified names if required in the function definition.
" }}}1
"=============================================================================
let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version   {{{2
function! lh#cpp#GotoFunctionImpl#version()
  return s:k_version
endfunction

" # Debug     {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#GotoFunctionImpl#verbose(...)
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

function! lh#cpp#GotoFunctionImpl#debug(expr) abort
  return eval(a:expr)
endfunction

function! lh#cpp#GotoFunctionImpl#force_api(api) abort
  " Used to force the API used in tests
  if empty(a:api)
    silent! unlet s:forced_api
  else
    let s:forced_api = a:api
  endif
endfunction

" # Script ID {{{2
function! s:getSID() abort
  return eval(matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_getSID$'))
endfunction
let s:k_script_name      = s:getSID()

" ## Functions {{{1
" # API {{{2
function! s:get_code_analyser() abort " {{{3
  if exists('s:forced_api')
    let api_kind = s:forced_api
  elseif lh#has#plugin('autoload/clang.vim') && clang#can_plugin_be_used()
    let api_kind = 'libclang'
  else
    let api_kind = 'vimscript'
  endif
  " call confirm("Using API: ".api_kind, "&OK", 1)
  return s:make_API(api_kind)
endfunction

function! s:make_API(kind) abort " {{{3
  let k_functions = ['get_namespace', 'get_classname', 'get_prototype', 'proto_to_regex',
        \ 'generate_definition_signature']
  let res = lh#object#make_top_type({'API': a:kind})
  for func in k_functions
    call lh#object#inject(res, func, a:kind.'_'.func, s:k_script_name)
  endfor
  return res
endfunction

" Vimscript API {{{3
function! s:vimscript_get_namespace() dict abort " {{{4
  " Get the class name, if any -- thanks to cpp_FindContextClass.vim
  if ! has_key(self, '_namespace')
    let self._namespace = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), 'namespace')
  endif
  return self._namespace
endfunction

function! s:vimscript_get_classname() dict abort " {{{4
  " Get the class name, if any -- thanks to cpp_FindContextClass.vim
  if ! has_key(self, '_classname')
    let self._classname = lh#cpp#AnalysisLib_Class#CurrentScope(line('.'), '##')
  endif
  return self._classname
endfunction

function! s:vimscript_get_prototype(opt) dict abort " {{{4
  let onlyDeclaration      = get(a:opt, 'onlyDeclaration', 0)
  let returnEndProtoExtent = get(a:opt, 'returnEndProtoExtent', 0)
  let res = call('lh#dev#c#function#get_prototype', [line('.'), onlyDeclaration, returnEndProtoExtent])
  if returnEndProtoExtent
    let self._end_proto = res[0]
    let self._proto = res[1]
  else
    let self._proto = res
  endif
  return res
endfunction

function! s:vimscript_proto_to_regex() dict abort " {{{4
  let impl2search = s:BuildRegexFromImpl(self._proto,self._classname)
  return impl2search
endfunction

function! s:vimscript_generate_definition_signature() dict abort " {{{4
  return s:BuildFunctionSignature4impl(self._proto,self.get_classname())
endfunction

" libclang API {{{3
function! s:tpl_extent_up_to_assign(tpl_info) abort " {{{4
  let l_res = clang#extract_from_extent(a:tpl_info.extent, 'template '.a:tpl_info.spelling)
  let res = join(l_res, "\n")
  " NB: more care may be required on this part
  let res = substitute(res, '\s*=.*', '', '')
  return res
endfunction

function! s:libclang_get_namespace() dict abort " {{{4
  if ! has_key(self, '_namespace')
    " TODO: check this is not a list
    let self._namespace = pyxeval('findNamespace().spelling')
  endif
  return self._namespace
endfunction

function! s:libclang_get_classname() dict abort " {{{4
  if ! has_key(self, '_classname')
    let self._classname = pyxeval('findClass().spelling')
  endif
  return self._classname
endfunction

function! s:libclang_get_prototype(opt, ...) dict abort " {{{4
  let onlyDeclaration      = get(a:opt, 'onlyDeclaration', 0)
  let returnEndProtoExtent = get(a:opt, 'returnEndProtoExtent', 0)

  let self._info = lh#cpp#AnalysisLib_Function#get_function_info(line('.'), onlyDeclaration)
  call s:Verbose("get_prototype() info: %1", self._info)
  let scope = get(self._info, 'scope', [])
  let namespace = []
  let classname = []
  let templates = []
  for sc in reverse(scope)
    call s:Verbose("scope: %1", sc)
    let name = sc.name
    if sc.kind =~ 'TEMPLATE'
      let inst     = []
      let tpl_line = []
      for tpl in sc.tparams
        let inst     += [tpl.spelling]
        let tpl_line += [s:tpl_extent_up_to_assign(tpl)]
      endfor
      let name .= '<'.join(inst, ',').'>'
      let line = 'template<'.join(tpl_line, ',').'>'
      let templates += [line]
      let classname += [name]
    elseif sc.kind =~ 'NAMESPACE'
      let namespace += [name]
    else
      let classname += [name]
    endif
  endfor
  " let self._classname = get(scope, 0, '')
  let self._namespace = join(namespace, '::')
  let self._classname = self._namespace . '#::#' . join(classname, '::')
  let self._templates = templates
  let self._proto     = get(self._info, 'fullsignature', '')
  return self._proto
endfunction

function! s:libclang_proto_to_regex() dict abort " {{{4
  " TODO: problems to fix
  " - libclang adds complete type scopes
  " - libclang returns west-const qualified types
  let impl2search = s:BuildRegexFromImpl(self._proto, self.get_classname())
  let impl2search.isWithoutDefinition = !empty(self._info.special_definition)
  let impl2search.ispure = self._info.pure
  return impl2search
endfunction

function! s:libclang_generate_definition_signature() dict abort " {{{4
  let res = s:BuildFunctionSignature4implFromFunctionInfo(self._info, self._classname)
  if !empty(self._templates)
    let res = join(self._templates + [res], "\n")
  endif
  return res
endfunction

"------------------------------------------------------------------------
"------------------------------------------------------------------------
" # Public {{{2
"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#MoveImpl() "{{{3
" The default values for 'HowToShowVirtual', 'HowToShowStatic' and
" 'HowToShowDefaultParams' can be overridden momentarily.
" Parameters: None
function! lh#cpp#GotoFunctionImpl#MoveImpl(...) abort
  try
    let a_save = @a
    let s      = @/

    let [end_proto, proto] = lh#dev#c#function#get_prototype(line('.'), 0, 1)
    if empty(proto)
      throw "No prototype found under the cursor."
    endif
    " move to the start of the definition
    call setpos('.', end_proto) " this puts us one char behind the definition start
    if lh#position#char_at_mark('.') !~ '[:{]'
      normal! h
    endif
    if proto[-1:] == ':'
      " select everything till the open bracket.
      " this won't work with C++11 initialiser-lists extended to {}
      silent exe "normal! \"ad/{\<cr>"
    else
      let @a = ''
    endif
    silent normal! "Ad%
    " For some reason, the previous command insert a leading newline
    let @a = substitute(@a, '^\_s*', '', '')
    " Add the ';' at the end what precedes, but not on a single line
    call search('\S', 'b')
    silent :exe "normal! A;\<esc>"
    " Search the prototype (once again!), from a compatible position (on the
    " closing bracket)
    call search(')', 'b')
    " TODO: For now, search the protype once again...
    " `"Ad%` sets regtype to "V". When pasted, it introduces a newline
    " => we need to prevent that
    if exists('*setreg')
      call setreg('a', @a, 'v')
    endif
    :exe "normal! :GOTOIMPL ".join(a:000, ' ')."\<cr>va{\"ap=a{"
    " was:
    " :exe "normal! \<home>f{\"ac%;\<esc>:GOTOIMPL ".join(a:000, ' ')."\<cr>va{\"ap=a{"
  finally
    let @a = a_save
    let @/ = s
  endtry
endfunction

"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#GrabFromHeaderPasteInSource "{{{3
" The default values for 'HowToShowVirtual', 'HowToShowStatic' and
" 'HowToShowDefaultParams' can be overridden momentarily.
" Parameters: 'ShowVirtualon', 'ShowVirtualoff', 'ShowVirtual0', 'ShowVirtual1',
"             'ShowStaticon', '..off', '..0' or '..1'
"             'ShowExplicitcon', '..off', '..0' or '..1'
"             'ShowDefaultParamson', '..off', '..0', '..1',  or '..2'
" TODO: add C++11 override and final
let s:option_value = '\%(on\|off\|\d\+\)$'

function! lh#cpp#GotoFunctionImpl#GrabFromHeaderPasteInSource(...) abort
  let code_analyser = s:get_code_analyser()
  let expected_extension = call('s:CheckOptions', a:000)
  let ft = &ft

  " 1- Retrieve the context {{{4
  " 1.1- Get the whole prototype of the function (even if on several lines)
  let proto = code_analyser.get_prototype({'onlyDeclaration': 1})
  if empty(proto)
    call lh#common#error_msg('cpp#GotoFunctionImpl.vim: We are not upon the declaration of a function prototype!')
    return
  endif

  " 1.2- Get the class name, if any
  let className = code_analyser.get_classname()

  " 2- Build the result strings {{{4
  try
    let isk_save = &isk
    set isk-=:
    let impl2search = code_analyser.proto_to_regex()
    if impl2search.isWithoutDefinition
      call lh#common#error_msg("cpp#GotoFunctionImpl.vim:\n\n".
            \ "=delete and =default functions don't have an implementation!")
      return
    endif
    if impl2search.ispure
      call lh#common#error_msg("cpp#GotoFunctionImpl.vim:\n\n".
            \ "Pure virtual functions don't have an implementation!")
      " TODO: actually, they can have one. Add a confirm dialog
      return
    endif

    " 3- Add the string into the implementation file {{{4
    call lh#cpp#GotoFunctionImpl#open_cpp_file(expected_extension)
    if &ft != ft
      exe 'setf '.ft
    endif

    " Search or insert the C++ implementation
    if !s:Search4Impl((impl2search.regex).'\_s*[{:]', className)
      let impl        = code_analyser.generate_definition_signature()
      " Todo: Support looking into other files like the .inl file

      " Insert the C++ code at the end of the file
      call lh#cpp#GotoFunctionImpl#insert_impl(impl, code_analyser)
    else
      call s:Verbose("Implementation for %1 found in %2:%3", code_analyser._proto, expand('%'), line('.'))
    endif
  finally
    let &isk = isk_save
  endtry

  " call confirm(impl, '&ok', 1)
  " }}}4
endfunction

"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#insert_impl(impl [, context]) {{{3
" @param {context} "type" is the code analyser one
function! lh#cpp#GotoFunctionImpl#insert_impl(impl, ...) abort
  let context = a:0 > 1 ? a:1 : s:get_code_analyser()
  let p = s:SearchLineToAddImpl(context)
  if -1 != p
    call s:InsertCodeAtLine(a:impl, p)
    let s:FunctionImpl = a:impl
  else
    " Otherwise, we use a method somehow like the one used by Robert:
    " We store the text to insert in a specific variable and wait for manual
    " insertion of the text.
    let s:FunctionImpl = a:impl
    call lh#common#warning_msg(":GOTOIMPL cannot determine where the function definition should be inserted."
          \ ."\nUse :PASTEIMPL to paste the code prepared."
          \ ."\nSee ftplugin/cpp/cpp_options.vim to tune the placement heuristic")
  endif
endfunction

"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#open_cpp_file(expected_extension) {{{3
function! lh#cpp#GotoFunctionImpl#open_cpp_file(expected_extension) abort
  call s:Verbose('Opening file with extension `%1`', a:expected_extension)
  if expand('%:e') =~? 'cpp\|c\|C\|cxx\|txx'
    " already within the .cpp file
    return
  endif
  try
    " neutralize mu-template jump to marker feature
    let cleanup = lh#on#exit()
          \.restore('g:mt_jump_to_first_markers')
    let g:mt_jump_to_first_markers = 0

    let split_opt = lh#cpp#GotoFunctionImpl#_find_alternates(a:expected_extension)
    if !empty(split_opt)
      let split_opt = lh#path#to_relative(split_opt)
      call s:DoSplit(split_opt)
    endif
  finally
    " restore mu-template
    call cleanup.finalize()
  endtry
endfunction

" Function: lh#cpp#GotoFunctionImpl#InsertCodeAtLine() {{{3
function! lh#cpp#GotoFunctionImpl#InsertCodeAtLine() abort
  return s:InsertCodeAtLine()
endfunction

" # Private {{{2

" Function: s:CheckOptions(...) {{{3
function! s:CheckOptions(...) abort
  " 0- Check options {{{4
  let s:ShowVirtual             = lh#ft#option#get('ShowVirtual',       &ft, 1)
  let s:ShowStatic              = lh#ft#option#get('ShowStatic',        &ft, 1)
  let s:ShowExplicit            = lh#ft#option#get('ShowExplicit',      &ft, 1)
  let s:ShowDefaultParams       = lh#ft#option#get('ShowDefaultParams', &ft, 1)
  let expected_extension        = ''
  if 0 != a:0
    let i = 0
    while i < a:0
      let i +=  1
      let varname = substitute(a:{i}, '\(.*\)'.s:option_value, '\1', '')
      if varname !~ 'ShowVirtual\|ShowStatic\|ShowExplicit\|ShowDefaultParams' " Error {{{5
        if !empty(expected_extension)
          call lh#common#error_msg(
                \ 'cpp#GotoFunctionImpl.vim::GrabFromHeaderPasteInSource: extension already set to <'.expected_extension.'>')
          return
        else
          let expected_extension = a:{i}
        endif
      else " }}}4
        let val = matchstr(a:{i}, s:option_value)
        if     val == 'on'  | let val = 1
        elseif val == 'off' | let val = 0
        elseif val !~ '\d\+'
          call lh#common#error_msg(
                \ 'cpp#GotoFunctionImpl.vim::GrabFromHeaderPasteInSource: Invalid value for parameter : <'.varname.'>')
          return
        endif
        " exe "let s:".varname."= val"
        let s:{varname} = val
        " call confirm(s:{varname}.'='.val, '&ok', 1)
      endif
    endwhile
  endif
  return expected_extension
endfunction
"------------------------------------------------------------------------
" Function: s:BestExtensionFor(root_name) {{{3
function! s:BestExtensionFor(root_name, expected_extension) abort
  if !empty(a:expected_extension) | return a:expected_extension | endif
  let Best_ext = lh#ft#option#get('ext_4_impl_file', &ft, 'cpp')
  let best_ext = type(Best_ext) == type(function('has'))
        \ ?  Best_ext(a:root_name)
        \ : Best_ext
  return best_ext
endfunction

"------------------------------------------------------------------------
" Function: s:BuildRegexFromImpl(impl,className) {{{3
" Build the regex that will be used to search the signature in the
" implementations file
function! s:BuildRegexFromImpl(impl,className) abort
  let impl2search=lh#cpp#AnalysisLib_Function#SignatureToSearchRegex(a:impl,a:className)
  let g:lh#cpp#GotoFunctionImpl#debug_impl2search  = impl2search
  return impl2search
  " }}}4
endfunction
"------------------------------------------------------------------------
" Function: s:Search4Impl(re_impl, scope):bool {{{3
function! s:Search4Impl(re_impl, scope) abort
  call s:Verbose("Searching for %1:: function definition w/ regex = %2", a:scope, a:re_impl)
  " 0- Pretransformations {{{4
  let required_ns = matchstr(a:scope, '^.*\ze#::#')
  " 1- Memorize position {{{4
  let l0 = line('.')
  " 2- Loop until the implementation is found, {{{4
  "    *and* the scope (namespaces) matches
  normal! gg
  " let l = 1
  while 1 " l > 0
    " a- search for an acceptable implementation {{{5
    "    Note: re_impl looks like :
    "    'type \(\(ns1::\)\=ns2::\)\=cl1::cl2::function(...)'
    let l = search(a:re_impl, 'W')
    if l <= 0 | break | endif

    " b- Get the current namespace at the line found {{{5
    let ns_list = lh#cpp#AnalysisLib_Class#available_namespaces(l)
    call s:Verbose("At line %1, namespaces are %2", l, ns_list)

    " c- Build the function name that must be found on the current line {{{5
    "    The function aname also contain the scope
    " let req_proto  = matchstr(required_ns, current_ns.
    " \ (current_ns == '') ? '.*$' : '::\zs.*$')

    " d- Retrieve the actual function name (+ relative scope) {{{5
    let z=@"
    let fe=&foldenable
    set nofoldenable
    let mv = l."gg".virtcol('.').'|'
    if search('(', 'W') <= 0
      " echoerr "Weird Error!!!"
    endif
    silent exe 'normal! v'.mv.'y'
    let &foldenable=fe
    let current_proto = matchstr(@", '\%(::\|\<\I\i*\>\|\<operator\>\s*\(||\|&&\|[-+*/^%=]=\=\)\=\|\~\)\+\ze($')
    let proto0= @"
    let @" = z
    " Todo: purge comments within current_proto

    " e- Check if really found {{{5
    for ns in ns_list
      " if match(required_ns, '^'.ns) == 0
      " \ && (req_proto == current_proto)
      let current = ns . ((ns != "") ? '::' : '' ).current_proto
      if ("" != required_ns) && (required_ns !~ '.*::$')
        let required_ns .=  '::'
      endif
      call s:Verbose("required_ns=%1\ncurrent_proto=%2\ncurrent_ns=%3\n#%4 -> %5", required_ns, current_proto, ns, l, getline('.'))
      " call confirm('required_ns='.required_ns.
      " \ "\ncurrent_proto=".current_proto.
      " \ "\ncurrent_ns=".ns.
      " \ "\n".l."=".getline('.').
      " \ "\n\nmv=".mv."\nproto0=".proto0."\ncurrent=".current,
      " \ '&ok', 1)
      " \ "\n\nreq_proto=".req_proto.
      if match(current,'^'.required_ns) == 0
        return l
      endif
    endfor
    " }}}5
  endwhile

  " 2.b- Not found {{{4
  exe l0
  return 0
  " }}}4
endfunction
"------------------------------------------------------------------------
" Function: s:BuildFunctionSignature4impl " {{{3
let s:k_operators = '\<operator\%([=~%+-\*/^&|]\|[]\|()\|&&\|||\|->\|<<\|>>\)'
function! s:BuildFunctionSignature4impl(proto,className) abort
  let info = lh#cpp#AnalysisLib_Function#AnalysePrototype(a:proto)
  let g:lh#cpp#GotoFunctionImpl#debug_funcinfo = info
  return s:BuildFunctionSignature4implFromFunctionInfo(info, a:className)
endfunction

"------------------------------------------------------------------------
" Function: s:BuildFunctionSignature4implFromFunctionInfo " {{{3
function! s:BuildFunctionSignature4implFromFunctionInfo(info,className) abort
  call s:Verbose("Build function signature for %1 (in class: %2)", a:info, a:className)
  let re_qualifiers = []
  " 1.a- XXX if you want virtual commented in the implementation: {{{4
  if s:ShowVirtual
    let re_qualifiers += ['\<virtual\>']
  endif

  " 1.b- XXX if you want static commented in the implementation: {{{4
  if s:ShowStatic
    let re_qualifiers += ['\<static\>']
  endif

  " 1.b- XXX if you want explicit commented in the implementation: {{{4
  if s:ShowExplicit
    let re_qualifiers += ['\<explicit\>']
  endif
  let comments = matchstr(a:info.qualifier, join(re_qualifiers, '\|'))
  if !empty(comments)
    let comments = '/*'.comments.'*/ '
  endif

  " 2- Handle default params, if any. {{{4
  "    0 -> ""              : ignored
  "    1 -> "/* = value */" : commented
  "    2 -> "/*=value*/"    : commented, spaces trimmed
  "    3 -> "/*value*/"     : commented, spaces trimmed, no equal sign
  if     s:ShowDefaultParams == 0 | let pattern = '\2'
  elseif s:ShowDefaultParams == 1 | let pattern = '/* = \1 */\2'
  elseif s:ShowDefaultParams == 2 | let pattern = '/*=\1*/\2'
  elseif s:ShowDefaultParams == 3 | let pattern = '/*\1*/\2'
  else                            | let pattern = '\2'
  endif
  "

  let implParams = []
  for param in a:info.parameters
    call s:Verbose("Parameter: %1", param)
    " TODO: param type may need to be fully-qualified, see 4.2
    let sParam = (get(param, 'nl', 0) ? "\n" : '')
          \ . (param.type) . ' ' . (param.name)
          \ . substitute(get(param, 'default', ''), '\(.\+\)', pattern, '')
    " echo "param=".param
    call add(implParams, sParam)
  endfor
  let implParamsStr = join(implParams, ', ')
  " @todo: exceptions specifications

  " 3- Add '::' to the class name (if any).{{{4
  let className = a:className . (""!=a:className ? '::' : '')
  let className = substitute(className, '^#::#', '', '')
  " let impl = substitute(impl, '\%(\~\s*\)\=\%(\<\i\+\>\|'.s:k_operators.'\)\('."\n".'\|\s\)*(',
  " \ className.'\0', '')

  " 4- Add scope to other types {{{4
  " 4.1- ... return type
  " return type is stored in function signature extracted by ... ctags
  let session = lh#tags#session#get()
  let ltags   = session.tags
  call session.finalize()
  let all_ret_dicts = filter(copy(ltags), 'v:val.name == '.string(a:info.return))
  let all_rets = lh#list#get(all_ret_dicts, 'class', '')
  " let all_rets = lh#list#transform(all_ret_dicts, [], 'v:1_.class')
  let all_rets = lh#list#unique_sort(all_rets)
  if len(all_rets) > 1
    let all_rets = ['::'] + all_rets
    let choice = lh#ui#confirm('Where does <'.(a:info.return).'> comes from?',
          \ join(all_rets, "\n"), 1)
    if     choice == 0 | let scope = []
    elseif choice == 1 | let scope = ['']
    else               | let scope = [all_rets[choice-1]]
    endif
  elseif len(all_rets) == 1
    let scope = all_rets
  else
    let scope = []
  endif
  let scope += [a:info.return]
  let return = join(scope, '::')
  " 4.2- ... parameters types
  " 4.3- ... constexpr
  " TODO: Check: not sure this really makes sense: constexpr function shall
  " be inlined
  if get(a:info, 'constexpr', 0)
    let return = 'constexpr ' . return
  endif

  " 5- Exceptions {{{4
  let noexcept
        \ = empty(a:info.noexcept)        ? ''
        \ : a:info.noexcept == 'noexcept' ? ' noexcept'
        \ :                                 ' noexcept('.(a:info.noexcept).')'

  " 6- Templates {{{4
  if !empty(get(a:info, 'tparams', []))
    " let g:tparams = a:info.tparams
    let tpl_list = map(copy(a:info.tparams), 's:tpl_extent_up_to_assign(v:val)')
    let tpl = 'template<'.join(tpl_list, ',').">\n"
    let comments = tpl.comments
  endif
  " 7- Return {{{4
  " TODO: some styles like to put return types and function names on two
  " different lines
  let unstyled = comments
        \ . return . ' '
        \ . className
        \ . (type(a:info.name) == type('') ? a:info.name : join(a:info.name, '::'))
        \ . '('.implParamsStr . ')'
        \ . (a:info.const         ? ' const'    : '')
        \ . (a:info.volatile      ? ' volatile' : '')
        \ . (!empty(a:info.throw) ? ' throw ('.join(a:info.throw, ',').')' : '')
        \ . noexcept
        \ . "{}"
  let styles = lh#style#get(&ft)

  let res = unstyled
  if !empty(styles)
    let styled = lh#style#apply(unstyled)
    let res = styled
  endif

  return res
  "}}}4
endfunction
"------------------------------------------------------------------------
" Function: s:SearchLineToAddImpl(context) {{{3
" @return line number where the function will be inserted
function! s:SearchLineToAddImpl(context) abort
  let Position = lh#ft#option#get('FunctionPosition', &ft, 0)
  " Default value for FunctionPosArg may change depending on FunctionPosition
  if type(Position) == type(function('has'))         " -- function (direct) {{{4
    return Position()
  elseif Position == 1 || Position ==? 'search'      " -- search pattern {{{4
    " Default: EOF
    let FunctionPosArg   = lh#ft#option#get('FunctionPosArg',   &ft, '\%$')
    let s=search(FunctionPosArg)
    if 0 == s
      call lh#common#error_msg("cpp#GotoFunctionImpl.vim: Can't find the pattern\n".
            \'   <(bpg):cpp'.&ft.'_FunctionPosArg>: '.FunctionPosArg)
      return -1
    else
      return s
    endif
  elseif Position == 0 || Position ==? 'end'         " -- offset from end {{{4
    let FunctionPosArg   = lh#ft#option#get('FunctionPosArg',   &ft, 0)
    return line('$') - FunctionPosArg
  elseif Position == 2                               " -- function (indirect) {{{4
    let FunctionPosArg   = lh#ft#option#get('FunctionPosArg',   &ft)
    if lh#option#is_unset(FunctionPosArg)
      call lh#common#error_msg('cpp#GotoFunctionImpl.vim: No positionning '.
            \ 'function defined thanks to <(bpg):cpp'.&ft.'_FunctionPosArg>')
      return -1
    elseif type(FunctionPosArg) == type(function('has'))
      return FunctionPosArg()
    elseif (type(FunctionPosArg) == type('')) && !exists('*'.FunctionPosArg)
      call lh#common#error_msg('cpp#GotoFunctionImpl.vim: The function '.
            \ '<(bpg):cpp'.&ft.'_FunctionPosArg> is not defined')
      return -1
    endif
    exe "return ".FunctionPosArg."()"
  elseif Position == 3 || Position ==? 'no'          " -- non-automatic insertion {{{4
    return -1
  elseif Position == 4 || Position ==? 'namespace'   " -- non-automatic insertion {{{4
    let ns = a:context.get_namespace()
    " TODO: search ns, or using ns
    " TODO: keep order in sync with class, or sort functions
    return -1 " for now...
  endif " }}}4
endfunction

"------------------------------------------------------------------------
" Function: s:InsertCodeAtLine([code [,line]]) {{{3
function! s:InsertCodeAtLine(...) abort
  if     a:0 >= 2 | let p = a:2+1     | let impl = a:1
  elseif a:0 >= 1 | let p = line('.') | let impl = a:1
  else            | let p = line('.') | let impl = s:FunctionImpl
  endif
  " Check namespace value
  let ns = lh#cpp#AnalysisLib_Class#CurrentScope(p, 'namespace')
  let ns0 = ns
  let impl0 = impl
  " call confirm('ns  ='.ns."\nimpl=".impl, '&Ok', 1)
  while ns != ""
    let n0 = matchstr(ns, '^.\{-}\ze\%(::\|$\)')
    if impl =~ '\s'.n0.'\%(::\|#::#\)'
      " call confirm('trim: '.n0, '&OK', 1)
      let impl = substitute(impl, '\(\s\)'.n0.'\%(::\|#::#\)', '\1', 'g')
    else
      call lh#common#error_msg( 'cpp#GotoFunctionImpl.vim: Namespaces mismatch!!!'.
            \ "\n\nCan't insert <".
            \ matchstr(impl0, '\%(::\|#::#\|\<\I\i*\>\)*\ze\_s*(').
            \ '> within the namespace <'.ns.'>')
      return
    endif
    let ns = matchstr(ns, '::\zs.*$')
    " call confirm('ns  ='.ns."\nimpl=".impl, '&Ok', 1)
  endwhile
  " Change my namespace delimiters (#::#) to normal scope delimiters (::)
  let impl = substitute(impl, '#::#', '::', '')
  " Unfold folders otherwise there could be side effects with ':put'
  let folder=&foldenable
  set nofoldenable
  " Insert the default function implementation at position 'p'
  if p > line('$')
    if getline('$') !~ '^\s*$'
      let impl="\n".impl
    endif
    let p=line('$')
  endif
  let l_impl = split(impl, '\n', 1)
  call append(p, l_impl)
  " Reindent the newly inserted lines
  let nl = len(l_impl) - 1
  let p += 1
  silent exe p.','.(p+nl).'v/^$/normal! =='
  " Restore folding
  let &foldenable=folder
endfunction
"------------------------------------------------------------------------
" Function: lh#cpp#GotoFunctionImpl#_find_alternates(expected_extension) {{{3
function! lh#cpp#GotoFunctionImpl#_find_alternates(expected_extension) abort
  let files = lh#alternate#_find_alternates() " on current file
  if len(files.existing) == 1
    return files.existing[0]
  elseif !empty(files.existing)
    let lFiles = files.existing
  else
    let lFiles = files.theorical
  endif
  let result = lh#path#select_one(lFiles, "What should be the name of the new file?")
  return result
endfunction

"------------------------------------------------------------------------
" Split Options: {{{3
" Function: s:SplitOption() {{{4
" @return the type of split desired: "n)o split", "v)ertical" (default one) or
"         "h)orizontal"/
function! s:SplitOption() abort
  if exists('g:cpp_Split')
    if     g:cpp_Split =~ 'v\%[ertical]'   | return 'v'
    elseif g:cpp_Split =~ 'h\%[orizontal]' | return 'h'
    else                                   | return 'n'
    endif
  endif
  " default: vertical split
  return 'v'
endfunction

" Internal constants {{{4
" s:split_{a.vim or vim built-in commands}_{split n/h/v} = command to execute
" --a.vim
let s:split_a_n = 'A'
let s:split_a_h = 'AS'
let s:split_a_v = 'AV'

" --no a.vim
" @todo don't split if the buffer is opened (while the file does not exists
" yet)
let s:split_n_n = 'e'
let s:split_n_h = 'sp'
let s:split_n_v = 'vsp'

" Function: s:DoSplit(arg) {{{4
function! s:DoSplit(arg) abort
  call lh#buffer#jump(a:arg, s:split_n_{s:SplitOption()})
endfunction
" }}}2
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
