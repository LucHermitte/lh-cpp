"=============================================================================
" File:         syntax/cpp-c-cast.vim                             {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/lh-cpp>
" Version:      2.2.0
let s:k_version = '220'
" Created:      16th Dec 2015
" Last Update:  20th Apr 2016
"------------------------------------------------------------------------
" Description:	C++ syntax enhancements
" (*) detect C casts in C++
"
" Options:
" - |cpp_no_hl_c_cast| to disable the check
"
" Known bugs:
" - `decltype(auto) foo;`
" - `f(12)(13)(14)`
" }}}1
"=============================================================================
" {{{1 Syntax definitions
if get(g:, 'cpp_no_hl_c_cast', 0)
  finish
endif

silent! syn clear       cCast

" (int*)v
"   but exclude some operators like "and", "or", "xor", "not" with "@!"
"   and function specifiers: "const", "volatile", "final", "override", "throw", "noexcept"
syn match       cCast '\v\(.{-}\)\s*(<and>|<or>|<xor>|<not>|<const>|<volatile>|<throw>|<noexcept>|<final>|<override>)@!\w+'
" (int*)(expr)
"   "\w@!" is used to ignore double chained calls to operator()
"   -> f(12)(13) and f (12)(13) are ignored
"   -> (int*)(expr) is matched
syn match       cCast '\v(\w\s*)@<!\(.{-}\)\s*\(.{-}\)'

hi def link     cCast       SpellBad

" ========================================================================
" {{{1 Some mappings

" }}}1
"=============================================================================
" vim600: set fdm=marker:
