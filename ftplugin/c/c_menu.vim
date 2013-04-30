"=============================================================================
" $Id$
" File:		ftplugin/c/c_menu.vim                                 {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:	2.0.0
" Created:	14th Oct 2006
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	
" 	Various C++ menu definitions
" }}}1
"=============================================================================


"=============================================================================
" Avoid buffer reinclusion {{{1
let s:cpo_save=&cpo
set cpo&vim
if exists('b:loaded_ftplug_c_menu')
       \ && !exists('g:force_reload_c_menu')
  let &cpo=s:cpo_save
  finish
endif
let b:loaded_ftplug_c_menu = 200
 
" }}}1
"------------------------------------------------------------------------
" Commands and mappings {{{1
" Commands and mappings }}}1
"=============================================================================
" Avoid global reinclusion {{{1
if exists("g:loaded_c_menu") 
      \ && !exists('g:force_reload_c_menu')
  let &cpo=s:cpo_save
  finish 
endif
let g:loaded_c_menu = 200
" Avoid global reinclusion }}}1
"------------------------------------------------------------------------
" Menu      {{{1
let s:menu_prio = lh#option#get('c_menu_priority', '50', 'g')
let s:menu_name = lh#option#get('c_menu_name',     '&C++', 'g')

" 80 wizards
" 90 options
"
" --------------------------------------------------[ 50 debug with pyclewn
if exists(':Pyclewn')
  call lh#menu#make('n', s:menu_prio.'.50.1', s:menu_name.'.&Pyclewn.&Run', '<F5>', '', ':Crun<cr>')
  call lh#menu#make('n', s:menu_prio.'.50.2', s:menu_name.'.&Pyclewn.&Start', '', '', ':Cstart<cr>')
  call lh#menu#make('n', s:menu_prio.'.50.3', s:menu_name.'.&Pyclewn.&Stop', '', '', ':Cstop<cr>')
  exe 'amenu <silent> '.s:menu_prio.'.50.20 '.escape(s:menu_name.'.&Pyclewn.-20-', '\ '). ' <Nop>'
  call lh#menu#make('n', s:menu_prio.'.50.21', s:menu_name.'.&Pyclewn.Add &Breakpoint', '', '', ':Cbreak')
  call lh#menu#make('n', s:menu_prio.'.50.22', s:menu_name.'.&Pyclewn.Clear Breakpoint', '', '', ':Cclear')
  exe 'amenu <silent> '.s:menu_prio.'.50.30 '.escape(s:menu_name.'.&Pyclewn.-30-', '\ '). ' <Nop>'
  call lh#menu#make('n', s:menu_prio.'.50.31', s:menu_name.'.&Pyclewn.&Next', '', '', ':Cnext<cr>')
  call lh#menu#make('n', s:menu_prio.'.50.32', s:menu_name.'.&Pyclewn.&Step', '', '', ':Cstep<cr>')
  call lh#menu#make('n', s:menu_prio.'.50.33', s:menu_name.'.&Pyclewn.&Cont', '', '', ':Ccont<cr>')
  exe 'amenu <silent> '.s:menu_prio.'.50.98 '.escape(s:menu_name.'.&Pyclewn.-98-', '\ '). ' <Nop>'
  call lh#menu#make('n', s:menu_prio.'.50.99', s:menu_name.'.&Pyclewn.Help', '', '', ':Chelp<cr>')
endif

" --------------------------------------------------[ 100 help
exe 'amenu <silent> '.s:menu_prio.'.100 '.escape(s:menu_name.'.-100-', '\ '). ' <Nop>'
exe 'amenu <silent> '.s:menu_prio.'.100.1 '.
      \ escape(s:menu_name.'.&Help.&Contents', '\ ').
      \ ' :help lh-cpp-readme.txt<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.2 '.
      \ escape(s:menu_name.'.&Help.&Features', '\ ').
      \ ' :help lh-cpp-features<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.3 '.
      \ escape(s:menu_name.'.&Help.&First Steps', '\ ').
      \ ' :help lh-cpp-first-steps<cr>'

exe 'amenu <silent> '.s:menu_prio.'.100.20.10 '.
      \ escape(s:menu_name.'.&Help.Code &snippets.&Brackets', '\ ').
      \ ' :help brackets-for-C<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.20.20 '.
      \ escape(s:menu_name.'.&Help.Code &snippets.&C snippets', '\ ').
      \ ' :help C_control-statements<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.20.20 '.
      \ escape(s:menu_name.'.&Help.Code &snippets.&C++ snippets', '\ ').
      \ ' :help C++_control-statements<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.20.100 '.
      \ escape(s:menu_name.'.&Help.Code &snippets.-100-', '\ '). ' <Nop>'
exe 'amenu <silent> '.s:menu_prio.'.100.20.100 '.
      \ escape(s:menu_name.'.&Help.Code &snippets.&Placeholders', '\ ').
      \ ' :help markers<cr>'

exe 'amenu <silent> '.s:menu_prio.'.100.50.10 '.
      \ escape(s:menu_name.'.&Help.&Wizards.&Accessors', '\ ').
      \ ' :help C++_accessors<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.50.20 '.
      \ escape(s:menu_name.'.&Help.&Wizards.&Goto Implementation', '\ ').
      \ ' :help C++_jump_implementation<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.50.30 '.
      \ escape(s:menu_name.'.&Help.&Wizards.&Override function', '\ ').
      \ ' :help C++_Override<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.50.40 '.
      \ escape(s:menu_name.'.&Help.&Wizards.&Doxygen function', '\ ').
      \ ' :help C++_function_doxygenation<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.50.50 '.
      \ escape(s:menu_name.'.&Help.&Wizards.&C++ Templates', '\ ').
      \ ' :help C++_templates<cr>'
" -> class
" -> enum generator
exe 'amenu <silent> '.s:menu_prio.'.100.50.100 '.
      \ escape(s:menu_name.'.&Help.&Wizards.-100-', '\ '). ' <Nop>'
exe 'amenu <silent> '.s:menu_prio.'.100.50.100 '.
      \ escape(s:menu_name.'.&Help.&Wizards.mu&Template', '\ ').
      \ ' :help mu-template<cr>'

exe 'amenu <silent> '.s:menu_prio.'.100.80 '.
      \ escape(s:menu_name.'.&Help.See &Unmatched functions', '\ ').
      \ ' :help C++_unmatched_functions<cr>'
exe 'amenu <silent> '.s:menu_prio.'.100.90 '.
      \ escape(s:menu_name.'.&Help.-90-', '\ '). ' <Nop>'
exe 'amenu <silent> '.s:menu_prio.'.100.90 '.
      \ escape(s:menu_name.'.&Help.&API', '\ ').
      \ ' :help lh-cpp-API<cr>'


" Functions {{{1
" Functions }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
