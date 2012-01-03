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

fun! ftimproved#FTCommand(f, fwd, mode) "{{{1
	let cnt  = v:count1
	let char = nr2char(getchar())
	if  char == ""
		" abort when Escape has been hit
		return char
	endif
	let char='\V'.escape(char, '\')
	let cmd  = (a:fwd ? '/' : '?')
	let off  = cmd
	let res  = ''
	if a:f
		" Searching using 'f' command
		if a:mode == 'o'
			let off .= (a:fwd ? 'e' : 's')
		endif
		let res = cmd.char.off."\n"
	else
		" Searching using 't' command
		if a:mode =~? 'o\|v\|'
			"let off  .= (a:fwd ? 's' : 'e') . 
			"	\ (a:mode == 'v' ? '-' : '')
			let off  .= (a:fwd ? 's-' : 'e+')
		else
			let off  .= (a:fwd ? 'e-' : 'e+')
		endif
		let counter = 1
		let oldpos = getpos('.')
		while cnt >= counter
			let tline = search(char, (a:fwd ? '' : 'b') .'W')
			let counter += 1
		endw
		if tline != oldpos[1] && match(getline(tline), '^'.char) == 0
			let res = cmd.char.off."\n"
		else
			let res = cmd.char.off."\n"
		endif
	endif
	return res ":call histdel('/', -1)\n"
endfun

fun! <sid>Map(lhs, rhs) "{{{1
	if !hasmapto(a:rhs, 'nvo')
		for mode in split('nvo', '\zs')
			exe mode. "noremap <silent> <expr> <unique>" a:lhs
					\ substitute(a:rhs, 'X', '"'.mode.'"', '')
		endfor
	endif
endfun

fun! <sid>Unmap(lhs) "{{{1
	if hasmapto('ftimproved#FTCommand', 'nov')
		exe "nunmap" a:lhs
		exe "vunmap" a:lhs
		exe "ounmap" a:lhs
	endif
endfun

fun! ftimproved#Activate(enable) "{{{1
	if a:enable
		call <sid>Map('f', 'ftimproved#FTCommand(1,1,X)')
		call <sid>Map('F', 'ftimproved#FTCommand(1,0,X)')
		call <sid>Map('t', 'ftimproved#FTCommand(0,1,X)')
		call <sid>Map('T', 'ftimproved#FTCommand(0,0,X)')
	else
		call <sid>Unmap('f')
		call <sid>Unmap('F')
		call <sid>Unmap('t')
		call <sid>Unmap('T')
	endif
endfun

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" Modeline {{{1
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdl=0
