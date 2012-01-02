" ftimproved.vim - Better f/t command for Vim
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
set cpo&vim

fun! ftimproved#FTCommand(f, fwd) "{{{1
	let cnt  = v:count1
	let char = nr2char(getchar())
	if  char == ""
		" abort when Escape has been hit
		return char
	endif
	let cmd  = (a:fwd ? '/' : '?') . '\V'
	let off  = (a:fwd ? '/e-' : '?e+')
	let res  = ''
	if a:f
		" Searching using 'f' command
		let res = cmd.escape(char, '\')
	else
		" Searching using 't' command
		let counter = 1
		while v:count1 >= counter
			let tline = search('\V'.escape(char, '\'), 'nW')
			let counter += 1
		endw
		if tline != line('.') && matchstr(getline(tline), '^'.char)
			let res = cmd.'$'
		else
			let res = cmd.escape(char, '\').off
		endif
	endif
	return res."\n"
endfun

fun! ftimproved#Activate(enable) "{{{1
	if a:enable
		if !hasmapto('<Plug>F_Cmd_forward')
			nnoremap <silent> <expr> <unique> f ftimproved#FTCommand(1,1)
			onoremap <silent> <expr> <unique> f ftimproved#FTCommand(1,1)
		endif

		if !hasmapto('<Plug>F_Cmd_backward')
			nnoremap <silent> <expr> <unique> F ftimproved#FTCommand(1,0)
			onoremap <silent> <expr> <unique> F ftimproved#FTCommand(1,0)
		endif

		if !hasmapto('<Plug>T_Cmd_forward')
			nnoremap <silent> <expr> <unique> t ftimproved#FTCommand(0,1)
			onoremap <silent> <expr> <unique> t ftimproved#FTCommand(0,1)
		endif

		if !hasmapto('<Plug>T_Cmd_backward')
			nnoremap <silent> <expr> <unique> T ftimproved#FTCommand(0,0)
			onoremap <silent> <expr> <unique> T ftimproved#FTCommand(0,0)
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
