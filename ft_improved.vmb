" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/ft_improved.vim	[[[1
45
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
" Init: {{{1
let s:cpo= &cpo
if exists("g:loaded_ft_improved") || &cp
  finish
endif
set cpo&vim
let g:loaded_ft_improved = 1

" ----------------------------------------------------------------------------
" Define the Mapping: "{{{2

"noremap <script> <Plug>F_Cmd_forward  <sid>F_Cmd_fw
"noremap <script> <Plug>F_Cmd_backward <sid>F_Cmd_bw
"noremap <script> <Plug>T_Cmd_forward  <sid>T_Cmd_fw
"noremap <script> <Plug>T_Cmd_backward <sid>T_Cmd_bw
"
"noremap <sid>F_Cmd_fw ft_improved#FTCommand(1,1)
"noremap <sid>F_Cmd_bw ft_improved#FTCommand(1,0)
"noremap <sid>T_Cmd_fw ft_improved#FTCommand(0,1)
"noremap <sid>T_Cmd_bw ft_improved#FTCommand(0,0)

com! DisableImprovedFT :call ftimproved#Activate(0)
com! EnableImprovedFT  :call ftimproved#Activate(1)

call ftimproved#Activate(1)

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\"
autoload/ftimproved.vim	[[[1
96
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
doc/ft_improved.txt	[[[1
79
ft_improved Better f/t command for Vim

Author:  Christian Brabandt <cb@256bit.org>
Version: 0.1 Mon, 02 Jan 2012 21:33:50 +0100

Copyright: (c) 2009, 2010, 2011, 2012 by Christian Brabandt
           The VIM LICENSE applies to improved_ft.vim and improved_ft.txt
           (see |copyright|) except use improved_ft instead of "Vim".
           NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.


==============================================================================
1. Contents                                                  *improvedft-ft*

        1.  Contents...................................: |improvedft-ft|
        2.  Manual.....................................: |improvedft-manual|
        2.1   Enable...................................: |improvedft-Enable|
        2.2   Disable..................................: |improvedft-Disable|
        3.  Feedback...................................: |improvedft-feedback|
        4.  History....................................: |improvedft-history|

==============================================================================
2. Improved ft command Manual                              *improvedft-manual*

Functionality

This plugin tries to improve the existing behaviour of the |f|, |F|, |t| and
|T| command by letting them move the cursor not only inside the current line,
but move to whatever line, where the character is found.

It does consider counts given and should work simply as a user would be
expecting.

It basically does that, by remapping the f,F,t and T command to issue a search
for the character that is entered and moving the cursor there.


2.1 Enable                                               *improvedft-Enable*
----------

By default the new f,F,t,T commands should simply work. If you have disabled
the plugin (see |improvedft-Disable|), use the command >
    :EnableImprovedFT
<

2.2 Disable                                             *improvedft-Disable*
-----------

If for any reason, you want to disable the plugin, use >
    :DisableImprovedFT
<

==============================================================================
3. Feedback                                         *improvedft-feedback*

Feedback is always welcome. If you like the plugin, please rate it at the
vim-page:
http://www.vim.org/scripts/script.php?script_id=3075

You can also follow the development of the plugin at github:
http://github.com/chrisbra/improvedft

Please don't hesitate to report any bugs to the maintainer, mentioned in the
third line of this document.

==============================================================================
4. History                                              *improvedft-history*

0.1: Jan 02, 2012 {{{1

- Initial upload
- development versions are available at the github repository
- put plugin on a public repository (http://github.com/chrisbra/improvedft)

  }}}

==============================================================================
Modeline:
vim:tw=78:ts=8:ft=help:et:fdm=marker:fdl=0:norl
