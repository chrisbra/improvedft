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
79
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
		if !hasmapto('ftimproved#FTCommand', 'no')
			nnoremap <silent> <expr> <unique> f ftimproved#FTCommand(1,1)
			onoremap <silent> <expr> <unique> f ftimproved#FTCommand(1,1)
			nnoremap <silent> <expr> <unique> F ftimproved#FTCommand(1,0)
			onoremap <silent> <expr> <unique> F ftimproved#FTCommand(1,0)
			nnoremap <silent> <expr> <unique> t ftimproved#FTCommand(0,1)
			onoremap <silent> <expr> <unique> t ftimproved#FTCommand(0,1)
			nnoremap <silent> <expr> <unique> T ftimproved#FTCommand(0,0)
			onoremap <silent> <expr> <unique> T ftimproved#FTCommand(0,0)
		endif
	else
		if hasmapto('ftimproved#FTCommand', 'no')
			nunmap f
			ounmap f
			nunmap F
			ounmap F
			nunmap t
			ounmap t
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
