" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/ft_improved.vim	[[[1
45
" ft_improved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.5
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Sat, 16 Feb 2013 23:21:31 +0100
"
" Script: 
" Copyright:   (c) 2009, 2010, 2011, 2012  by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3877 5 :AutoInstall: ft_improved.vim
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
392
" ftimproved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.5
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Sat, 16 Feb 2013 23:21:31 +0100
"
" Script: 
" Copyright:   (c) 2009, 2010, 2011, 2012  by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3877 5 :AutoInstall: ft_improved.vim
"
" Functions:
let s:cpo= &cpo
set cpo&vim

"Debug Mode:
let s:debug = 0

let s:escape = "\e"

fun! <sid>ReturnOperatorOffset(f_mot, fwd, mode) "{{{1
	" Return list with 2 items
	" item 0: operator, item 1: offset
	if a:f_mot
		" f-command
		if a:mode =~ 'o'
			" operator pending mode
			" :h o_v
			return ['v', '']
		endif
	else
		" t-command
		if a:mode =~? 'v\|'
			return ['', a:fwd ? 's-' : 'e']
		elseif a:mode !~ 'o'
			return ['', a:fwd ? 'e-' : 'e+']
		endif
	endif
	return ['', '']
endfun
fun! <sid>DebugOutput(string) "{{{1
	if s:debug
		echo strtrans(a:string)
	endif
endfun
fun! <sid>Opposite(char) "{{{1
	if a:char == '/' || a:char =~ '[ft]'
		return '?'
	else
		return '/'
	endif
endfun

fun! <sid>SearchForChar(char) "{{{1
	if a:char =~ '[ft]'
		return '/'
	else
		return '?'
	endif
endfun

fun! <sid>EscapePat(pat) "{{{1
	return '\V'.escape(a:pat, '\')
endfun

fun! <sid>ColonPattern(cmd, pat, off, f) "{{{1
	if !exists("s:colon")
		let s:colon = {}
	endif
	let pat = a:pat
	let cmd = a:cmd
	let opp = <sid>Opposite(a:cmd[-1:])
	let opp_off = <sid>Opposite(a:off[0])
	if a:cmd == 'f'
		let cmd = '/'
	elseif a:cmd == 'F'
		let cmd = '?'
	endif
	let s:colon[';'] = cmd[-1:]. pat. 
		\ (empty(a:off) ? cmd[-1:] : a:off)
	let s:colon[','] = cmd[:-2]. opp. pat.
	    \ (empty(a:off) ? opp : opp_off . a:off[1])
	let s:colon['cmd'] = a:f
endfun

fun! <sid>HighlightMatch(char) "{{{1
	if exists("s:matchid")
		sil! call matchdelete(s:matchid)
	endif
	if !empty(a:char)
		let s:matchid = matchadd('IncSearch', '\V'. a:char)
		redraw
	endif
endfu
fun! ftimproved#ColonCommand(f, mode) "{{{1
	" should be a noop
	if !exists("s:searchforward")
	    let s:searchforward = 1
	endif
	if s:searchforward
	    let fcmd = (a:f ? ';' : ',')
	else
	    let fcmd = (!a:f ? ';' : ',')
	endif
	if !exists("s:colon")
		let s:colon={}
		let s:colon[';']=''
		let s:colon[',']=''
		let s:colon['cmd'] = ''
	endif
	let res = ''
	let res = (empty(s:colon[fcmd]) ? fcmd : s:colon[fcmd])
	if a:mode =~ 'o' &&
		\ s:colon['cmd'] " last search was 'f' command
		" operator pending. For f cmd, make sure the motion is inclusive
		let res = 'v'.res
	endif
	if res != fcmd
		try
			let pat = matchlist(res, '^v\?\([/?]\)\(.*\)\1')
			" ?-search, means, we need to escape '?' in the pattern
			let spat = pat[2]
			if pat[1] =~ '[?/]'
				let pat[2] = escape(pat[2], pat[1])
				let res = pat[1] . pat[2] . pat[1]
			endif
			if !search(spat, (pat[1]=='?' ? 'b' : '').'nW') || 
				\ <sid>CheckSearchWrap(spat, pat[1]!='?', v:count1)
				" noop
				let res = ''
			endif
			if pat[1]=='?'
				let tline = search(spat, 'bnW')
				if tline < line('.') && getline(tline) =~ spat.'\$'
					" Match is in the last column of a previous line
					let res = substitute(res, '[/?]\zs[se][+-]$', '', '')
				endif
			endif
		catch
			" Most likely, the matchlist did not succeed.
			let res = ''
		endtry
	endif
	" Ctrl-C should be a noop
	let res = (empty(res) ? s:escape : res."\n")
	call <sid>DebugOutput(res)
	return res
endfun

fun! ftimproved#FTCommand(f, fwd, mode) "{{{1
	let char = nr2char(getchar())
	if  char == s:escape
		" abort when Escape has been hit
		return char
	endif
	if get(g:, "ft_improved_multichars", 0)
		call <sid>HighlightMatch(char)
		let next = getchar()
		while !empty(next) && ( next >= 0x20 ||
			\ ( len(next) == 3 && next[1] == 'k' && next[2] =='b'))
			if (len(next) == 3 && next[1] == 'k' && next[2] =='b') " <BS>
				let char=char[:-2]
			else
				let char .= nr2char(next)
			endif
			call <sid>HighlightMatch(char)
			let next = getchar()
		endw
		call <sid>HighlightMatch('')
		if  next == s:escape
			" abort when Escape has been hit
			return s:escape
		endif
	endif
	let no_offset = 0
	let cmd  = (a:fwd ? '/' : '?')
	let pat  = <sid>EscapePat(char)
	if !get(g:, "ft_improved_multichars", 0)
	" Check if normal f/t commands would work:
		if search(pat, 'nW') == line('.') && a:fwd
			let s:searchforward = 1
			let cmd = (a:f ? 'f' : 't')
			call <sid>ColonPattern(<sid>SearchForChar(cmd),
					\ pat, '', a:f)
			return cmd.char

		elseif search(pat, 'bnw') == line('.') && !a:fwd
			let s:searchforward = 0
			let cmd = (a:f ? 'F' : 'T')
			call <sid>ColonPattern(<sid>SearchForChar(cmd),
					\ pat, '', a:f)
			return cmd. char
		endif
	endif

	" Check if search would wrap
	if (search(pat, 'nW') == 0 && a:fwd) ||
		\  (search(pat, 'bnW') == 0 && !a:fwd)
		" return ESC
		call <sid>ColonPattern(<sid>SearchForChar(cmd),
				\ pat, '', a:f)
		return s:escape
	endif

	" ignore case of pattern? Does only work with search, not with original
	" f/F/t/T commands
	if !get(g:, "ft_improved_ignorecase", 0)
		let pat = '\c'.pat
	endif

	let cnt  = v:count1
	let off  = cmd
	let res  = ''
	let op_off = <sid>ReturnOperatorOffset(a:f, a:fwd, a:mode)
	if a:f
		" Searching using 'f' command
		"if a:mode == 'o'
			" There is a strange vi behaviour
			" Cite from Vim source code:
			"
			" * Imitate the strange Vi behaviour: If the delete spans more
            " * than one line and motion_type == MCHAR and the result is a
			" * blank line, make the delete linewise. 
			" * Don't do this for the change command or Visual mode.
			"if a:mode !~# 'v\|'
				" Not working correctly in Vim. This looks like a bug:
				" Message-ID: 20120104185216.GB9668@256bit.org
				" should be fixed with 7.3.396
				"let cmd = cnt . 'v' . cmd
			"endif
		"endif
		let cmd  = op_off[0].cmd
		let off .= op_off[1]
		let pat1  = (a:fwd ? pat : escape(pat, '?'))
		let res  = cmd.pat1.off."\n"
	else
		" Searching using 't' command
		let cmd  = op_off[0].cmd
		" if match is on previous line the last char, don't add offset
		if !a:fwd
			let tline=search(pat, 'bnW')
			if tline < line('.') && getline(tline) !~ pat.'\$'
				let off .= op_off[1]
			else
				let no_offset = 1
			endif
		else
			let off .= op_off[1]
		endif

		let pat1 = (a:fwd ? pat : escape(pat, '?'))
		let res = cmd.pat1.off."\n"
	endif

	if <sid>CheckSearchWrap(pat, a:fwd, cnt)
		let res = s:escape
	endif

	" save pattern for ';' and ','
	call <sid>ColonPattern(cmd, pat,
			\ off. (no_offset ? op_off[1] : ''), a:f)

	let pat = pat1
	call <sid>DebugOutput(res)
	return res ":call histdel('/', -1)\n"
endfun

fun! <sid>CheckSearchWrap(pat, fwd, cnt) "{{{1
	" Check, if search would warp around
	let counter = 1
	let oldpos  = getpos('.')

	while a:cnt >= counter
		let line = search(a:pat, (a:fwd ? '' : 'b') .'W')
		if !line
			" don't return anything, if the search would wrap around
			call setpos('.', oldpos)
			return 1
		endif
		let counter+=1
	endw
	call setpos('.', oldpos)
	return 0
endfun

fun! <sid>Map(lhs, rhs) "{{{1
	if !hasmapto(a:rhs, 'nxo')
		for mode in split('nxo', '\zs')
			exe mode. "noremap <silent> <expr> <unique>" a:lhs
					\ substitute(a:rhs, 'X', '"'.mode.'"', '')
		endfor
	endif
endfun

fun! <sid>Unmap(lhs) "{{{1
	"if hasmapto('ftimproved#FTCommand', 'nov')
	if !empty(maparg(a:lhs, 'nov'))
		exe "nunmap" a:lhs
		exe "xunmap" a:lhs
		exe "ounmap" a:lhs
	endif
endfun

fun! ftimproved#Activate(enable) "{{{1
	if a:enable
		" Disable the remapping of those keys by the yankring plugin
		" and reload the Yankring plugin
		" github issue #1
		let g:yr_mapped = [0, 0]
		if exists("g:loaded_yankring") &&
			\ g:loaded_yankring > 1
			" should make sure, the user didn't set this variable to simply
			" deactivate the plugin. If so, he probably only set it to 1...
			if exists(":YRToggle") == 2
				" turn off and on again yankring
				" first turn off with the original values of the variables,
				" so everything is disabled correctly
				sil YRToggle 0
				" now adjust the Yankring options
				if g:yankring_zap_keys =~# "[ft]"
					let g:yankring_zap_keys =
								\ substitute(g:yankring_zap_keys,
								\ '\c[ft] ', "", "g")
					let g:yr_mapped[0] = 1
				endif
				if g:yankring_o_keys =~ "[,;]"
					let g:yankring_o_keys =
								\ substitute(g:yankring_o_keys, '[,;] ',
								\ "", "g")
					let g:yr_mapped[1] = 1
				endif
				" enable the plugin again
				sil YRToggle 1
			endif
		else
			" YankRing wasn't loaded yet, so init those variables
			let g:yankring_zap_keys = "/ ?"
			let g:yankring_o_keys  = 'b B w W e E d h j k l H M L y G ^ 0 $'
			let g:yankring_o_keys .= ' g_  g^ gm g$ gk gj gg ge gE - + _ '
			let g:yankring_o_keys .= ' iw iW aw aW as is ap ip a] a[ i] i['
			let g:yankring_o_keys .= ' a) a( ab i) i( ib a> a< i> i< at it'
			let g:yankring_o_keys .= ' a} a{ aB i} i{ iB a" a'' a` i" i'' i`'
		endif
		" f,F,t,T should be unmaped now, so we can map it.
		call <sid>Map('f', 'ftimproved#FTCommand(1,1,X)')
		call <sid>Map('F', 'ftimproved#FTCommand(1,0,X)')
		call <sid>Map('t', 'ftimproved#FTCommand(0,1,X)')
		call <sid>Map('T', 'ftimproved#FTCommand(0,0,X)')
		call <sid>Map(';', 'ftimproved#ColonCommand(1,X)')
		call <sid>Map(',', 'ftimproved#ColonCommand(0,X)')
	else
		call <sid>Unmap('f')
		call <sid>Unmap('F')
		call <sid>Unmap('t')
		call <sid>Unmap('T')
		call <sid>Unmap(',')
		call <sid>Unmap(';')
		if exists("g:loaded_yankring") &&
			\ g:loaded_yankring > 1
			" should make sure, the user didn't set this variable to simply
			" deactivate the plugin. If so, he probably only set it to 1...
			if exists(":YRToggle") == 2
				" turn off and on again yankring
				sil YRToggle 0
				" reset the yankring options
				if g:yr_mapped[0]
					let g:yankring_zap_keys .= 'f F t T '
				else
					unlet! g:yankring_zap_keys
				endif
				if g:yr_mapped[1]
					let g:yankring_o_keys .= ', ; '
				else
					unlet! g:yankring_o_keys
				endif

				" enable Yankring, and reload the YankRing
				sil YRToggle 1
			endif
		endif
	endif
endfun

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" Modeline {{{1
" vim: ts=4 sts=4 fdm=marker com+=l\:\" fdl=0
doc/ft_improved.txt	[[[1
176
*ft_improved.txt* - Better f/t command for Vim

Author:  Christian Brabandt <cb@256bit.org>
Version: 0.5 Sat, 16 Feb 2013 23:21:31 +0100

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
        2.3   Tips.....................................: |improvedft-Tips|
        2.3.1 Using the YankRing.......................: |improvedft-YankRing|
        2.3.2 Ignoring case............................: |improvedft-ignorecase|
        2.4   Bugs.....................................: |improvedft-Bugs|
        3.  Feedback...................................: |improvedft-feedback|
        4.  History....................................: |improvedft-history|

==============================================================================
2. Improved ft command Manual                              *improvedft-manual*

Functionality

This plugin tries to improve the existing behaviour of the |f|, |F|, |t| and
|T| command by letting them move the cursor not only inside the current line,
but move to whatever line, where the character is found. Also the |,| and |;|
command should just work as expected.

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

2.3 Tips                                                  *improvedft-Tips*
--------
                                                        *improvedft-YankRing*

2.3.1 YankRing and the improved ft plugin
------------------------------------------

Both plugins map the ',', ';', 'f', 'F', 't' and 'T' key, so they don't work
together very well. The improved ft plugin tries to work around that by
setting a YankRing option that prevents mapping those keys and reloading the
YankRing plugin.

The following YankRing variables are set by the improved ft plugin: >

        let g:yankring_zap_keys = "/ ?"
        let g:yankring_o_keys  = 'b B w W e E d h j k l H M L y G ^ 0 $'
        let g:yankring_o_keys .= ' g_  g^ gm g$ gk gj gg ge gE - + _ '
        let g:yankring_o_keys .= ' iw iW aw aW as is ap ip a] a[ i] i['
        let g:yankring_o_keys .= ' a) a( ab i) i( ib a> a< i> i< at it'
        let g:yankring_o_keys .= ' a} a{ aB i} i{ iB a" a'' a` i" i'' i`'
<

If those variables have been customized in your .vimrc, the plugin detects it
and removes the ',', ';', 'f', 'F', 't' and 'T' from them.

The drawback of doing this is, that the YankRing possibly doesn't immediately
catch up in the YankRing itself and possibly will not be caught at all.

                                                    *improvedft-ignorecase*
2.3.2 Ignoring case when searching
----------------------------------

ft_improved tries to mimic the existing behaviour of the |f| |F| |t| |T| |,| |;|
commands as closely as possible. However, you might wish to search for the
character while ignoring case, so that fT will also jump to either the next
't' or 'T' character, whichever appears first.

To enable this, simply set this variable in your |.vimrc| >

    :let g:ft_improved_ignorecase = 1
<

To disable either |unlet| that variable, or set it to zero.

                                                    *improvedft-multichars*
2.3.3 Searching for more characters
-----------------------------------

ft_improved tries to mimic the existing behaviour of the |f| |F| |t| |T| |,| |;|
commands as closely as possible. However, you might wish to search for more
character to better find your position and not only allow one single char with
it.

To enable this, simply set this variable in your |.vimrc| >

    :let g:ft_improved_multichars = 1
<

To disable either |unlet| that variable, or set it to zero.

If you have enabled it this way, you need to press enter, after having entered
the characters to search for, so that the plugin knows, when not to wait for more
characters and to start searching.

Note: This is highly experimental and basically turns your |f| |F| |t| |T| |,|
|;| keys to use a literal search function.

2.4 Bugs                                             *improvedft-Bugs*
--------

- The plugin sets the search register (so 'hls' triggers incorrectly)
  (probably needs a rewrite without using expression-mappings)

- When using T as operator and the match is the last character of a previous
  line, the motion will become inclusive and you will incorrectly also change
  that character. (also when ',' or ';' are searching backwards) That seems to
  be a bug within Vim. See also |exclusive|

==============================================================================
3. Feedback                                         *improvedft-feedback*

Feedback is always welcome. If you like the plugin, please rate it at the
vim-page:
http://www.vim.org/scripts/script.php?script_id=3877

You can also follow the development of the plugin at github:
http://github.com/chrisbra/improvedft

Please don't hesitate to report any bugs to the maintainer, mentioned in the
third line of this document.

==============================================================================
4. History                                              *improvedft-history*

0.5: Feb 16, 2013 "{{{1
- ignorecase when searching, when g:ft_improved_ignorecase is set
  
0.4: Sep 09, 2012 "{{{1
- special handling of pattern / and ?

0.3: Aug 20, 2012 "{{{1
- fix issue https://github.com/chrisbra/improvedft/issues/1
  by disallowing the Yankring to map the keys f F t and T
- Better mapping of ';' key (patch by Marcin Szamotulski, thanks!)

0.2: Jan 13, 2012 {{{1
- disable debug mode
- enable |GLVS|

0.1: Jan 12, 2012 {{{1

- Initial upload
- development versions are available at the github repository
- put plugin on a public repository (http://github.com/chrisbra/improvedft)
  }}}

==============================================================================
Modeline:
vim:tw=78:ts=8:ft=help:et:fdm=marker:fdl=0:norl
