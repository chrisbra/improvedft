" ft_improved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.1
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Mon, 02 Jan 2012 21:33:50 +0100
"
" Script: 
" Copyright:   (c) 2009, 2010, 2011, 2012  by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: XXX 1 :AutoInstall: ft_improved.vim
"
" Functions:
let s:cpo= &cpo
if exists("g:loaded_ft_improved") || &cp
  finish
endif
set cpo&vim

fun! ft_improved#FTComand(f, fwd) "{{{1
	let char = nr2char(getchar())
	let cmd  = (a:fwd ? '/' : '?'). \V'
	let offset = (a:fwd ? '/' : '?')
	if a:f
		return v:count1.cmd.escape(char, '\')
	else
		let count = 1
		while v:count1 >= count
			let tline = search('\V'.escape(char, '\'), 'nW)
		endw
		if tline != line('.') && matchstr(getline(tline), '^'.char)
			return v:count1.cmd.'$'
		else
			return v:count1.cmd.escape(char, '\').offset.'e-1'
		endif
	endif
endfun

fun! ft_improved#Activate(enable) "{{{1
	if a:enable
		if !hasmapto('<Plug>F_Cmd_forward')
			nnoremap <silent> <expr> <unique> f <Plug>F_Cmd_forward
			onoremap <silent> <expr> <unique> f <Plug>F_Cmd_forward
		endif

		if !hasmapto('<Plug>F_Cmd_backward')
			nnoremap <silent> <expr> <unique> F <Plug>F_Cmd_backward
			onoremap <silent> <expr> <unique> F <Plug>F_Cmd_backward
		endif

		if !hasmapto('<Plug>T_Cmd_forward')
			nnoremap <silent> <expr> <unique> t <Plug>T_Cmd_forward
			onoremap <silent> <expr> <unique> t <Plug>T_Cmd_forward
		endif

		if !hasmapto('<Plug>T_Cmd_backward')
			nnoremap <silent> <expr> <unique> T <Plug>T_Cmd_backward
			onoremap <silent> <expr> <unique> T <Plug>T_Cmd_backward
		endif
	else
		if hasmapto('<Plug>F_Cmd_forward')
			nunmap f
			ounmap f
		endif

		if hasmapto('<Plug>F_Cmd_backward')
			nunmap F
			ounmap F
		endif

		if hasmapto('<Plug>T_Cmd_forward')
			nunmap t
			ounmap t
		endif

		if hasmapto('<Plug>T_Cmd_backward')
			nunmap T
			ounmap T
		endif
	endif
endfun

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" Modeline {{{1
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdl=0
