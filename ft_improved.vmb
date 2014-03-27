" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/ft_improved.vim	[[[1
45
" ft_improved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.8
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Thu, 27 Mar 2014 23:22:01 +0100
"
" Script: 
" Copyright:   (c) 2009, 2010, 2011, 2012  by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3877 8 :AutoInstall: ft_improved.vim
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
537
" ftimproved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.8
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Thu, 27 Mar 2014 23:22:01 +0100
" Script:  http://www.vim.org/scripts/script.php?script_id=3877
" Copyright:   (c) 2009 - 2013  by Christian Brabandt
"			   The VIM LICENSE applies to ft_improved.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3877 8 :AutoInstall: ft_improved.vim
"
" Functions:
let s:cpo= &cpo
set cpo&vim

" Debug Mode:
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
	if a:char =~# '[ft]'
		return '/'
	else
		return '?'
	endif
endfun

fun! <sid>EscapePat(pat, vmagic) "{{{1
	let pat = escape(a:pat, '\''')
	if pat ==# ''
		let pat = '\r'
	elseif pat ==# '	'
		let pat = '\t'
	" elseif pat ==# ''  " Will be skipped anyhow
	"	let pat = '\e'
	"
	" TODO: Other characters to take care of?
	endif
	return (a:vmagic ? '\V' : '').pat
endfun

fun! <sid>ColonPattern(cmd, pat, off, f, fwd) "{{{1
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
	if a:fwd
		let s:colon[';'] = cmd[-1:]. pat. 
			\ (empty(a:off) ? cmd[-1:] : a:off)
		let s:colon[','] = cmd[:-2]. opp. pat.
			\ (empty(a:off) ? opp : opp_off . a:off[1])
	else
		let s:colon[','] = cmd[-1:]. pat. 
			\ (empty(a:off) ? cmd[-1:] : a:off)
		let s:colon[';'] = cmd[:-2]. opp. pat.
			\ (empty(a:off) ? opp : opp_off . a:off[1])
	endif
	let s:colon['cmd'] = a:f
endfun

fun! <sid>HighlightMatch(char, dir) "{{{1
	if get(g:, 'ft_improved_nohighlight', 0)
		return
	endif
	if exists("s:matchid")
		sil! call matchdelete(s:matchid)
	endif
	let output=''
	"if !empty(a:char) && a:char !~# '\%(\\c\)\?\%(\V\)\?$'
	if !empty(matchstr(a:char, '^\%(\\c\)\?\\V\zs.*$'))
		let output = matchstr(a:char, '^\%(\\c\)\?\\V\zs.*')
		" remove escaping for display
		let output = substitute(output, '\\\\', '\\', 'g')
		if a:dir
			let pat = '\%(\%>'. col('.'). 'c\&\%'. line('.'). 'l'
			let pat .= '\|\%>'. line('.'). 'l\)'. a:char
			" Make sure, it only matches within the current viewport
			let pat = '\%('. pat. '\m\)\ze\&\%<'.(line('w$')+1).'l'.a:char
		else
			let pat = '\%(\%<'. col('.'). 'c\&\%'. line('.'). 'l'
			let pat .= '\|\%<'. line('.'). 'l\)'. a:char
			" Make sure, it only matches within the current viewport
			let pat = '\%('. pat. '\m\)\ze\&\%>'.(line('w0')-1).'l'.a:char
		endif
		let s:matchid = matchadd('IncSearch', pat)
		redraw!
		" Output input string after(!) redraw.
		if !empty(output)
			echohl Title
			exe ':echon '. string(output)
			echohl Normal
		endif
	else
		redraw! "clear screen"
	endif
endfu
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

fun! <sid>CountMatchesWin(pat, forward) "{{{1
	" Return number of matches of pattern window start and cursor (backwards)
	" or cursorline and window end line (forward search)
	" TODO: filter folded lines?
	if a:forward
		let first = line('.') + 1
		let last = line('w$')
		let cursorline = getline('.')[col('.')-1:]
	else
		let first = line('w0')
		let last = line('.')-1
		let cursorline = matchstr(getline('.'), '^.*\%'.col('.').'c')
	endif
	" Skip folded lines (they are not visible and won't be available for
	" jumping to.
	let buf = ''
	let line = first
	while line <= last
		if foldclosed(line) != -1
			let line = foldclosedend(line) + 1
			continue
		endif
		let buf .= getline(line) . "\n"
		let line+=1
	endw

	let buf .= "\n". cursorline
	return len(split(buf, a:pat.'\zs', 1)) - 1
endfu

fun! ftimproved#ColonCommand(f, mode) "{{{1
	" a:f f/F command, a:mode: map mode
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
			let pat = matchlist(res, '^v\?\([/?]\)\(.*\)\1\([bse].\)\?')
			" ?-search, means, we need to escape '?' in the pattern
			let spat = pat[2]
			if pat[1] =~ '[?/]'
				let pat[2] = escape(pat[2], pat[1])
				if !s:colon['cmd'] && pat[1] == '?' " t or T command
					" T command
					let res = pat[1]. '\('. pat[2]. '\m\)\@<=.' . pat[1]
				elseif !s:colon['cmd']
					" t command and forward search
					let res = pat[1]. '.\@>\(' . pat[2]. '\)'. pat[1]
				else
					let res = pat[1] . pat[2] . pat[1]
				endif
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
	" f: its an f-command
	" fwd: forward motion
	" mode: mapping mode
	try
		let char = nr2char(getchar())
		if  char == s:escape
			" abort when Escape has been hit
			return char
		elseif empty(char) || char ==? "\x80\xFD\x60" "CursorHoldEvent"
			return s:escape
		endif
		let orig_char = char
		let char  = <sid>EscapePat(char, 1)
		" ignore case of pattern? Does only work with search, not with original
		" f/F/t/T commands
		if get(g:, "ft_improved_ignorecase", 0)
			let char = '\c'.char
		endif
		if get(g:, "ft_improved_multichars", 0) &&
				\ <sid>CountMatchesWin(char, a:fwd) > 1
			call <sid>HighlightMatch(char, a:fwd)
			let next = getchar()
			" break on Enter, Esc or Backspace
			while !empty(next) && ((next !=? "\x80\xFD\x60" &&
						\ next != 13 &&
						\ next != 10 &&
						\ next != 27) || next == "\<BS>")
				if next == "\<BS>"
					" Remove one char
					let char = substitute(char, '\%(\\\\\|.\)$', '', '')
				else
					let char .= <sid>EscapePat(nr2char(next),0)
				endif

				" Get matches of pattern within the windows viewport
				let matches = <sid>CountMatchesWin(char, a:fwd)

				if matches == 0
					" no match within the windows viewport, abort
					return s:escape
				elseif matches == 1
					break
				endif

				if char =~# '^\%(\\c\)\?\\V$'
					" don't highlight empty pattern
					call <sid>HighlightMatch('', a:fwd)
				else
					call <sid>HighlightMatch(char, a:fwd)
				endif
				if !search(char, (a:fwd ? '' : 'b'). 'Wn')
					" Pattern not found, abort
					return s:escape
				endif
				" Get next character
				let next = getchar()
			endw
			if nr2char(next) == s:escape
				" abort when Escape has been hit
				return s:escape
			elseif empty(next) || next ==? "\x80\xFD\x60" "CursorHold Event"
				return s:escape
			endif
		endif
		let oldsearchpat = @/
		let no_offset = 0
		let cmd = (a:fwd ? '/' : '?')
		let pat = char
		if !get(g:, "ft_improved_multichars", 0)
		" Check if normal f/t commands would work:
			if search(matchstr(pat.'\C', '^\%(\\c\)\?\zs.*'), 'nW') == line('.')
				\ && a:fwd
				let s:searchforward = 1
				let cmd = (a:f ? 'f' : 't')
				call <sid>ColonPattern(<sid>SearchForChar(cmd),
						\ pat, '', a:f, a:fwd)
				return cmd.orig_char

			elseif search(matchstr(pat.'\C', '^\%(\\c\)\?\zs.*'), 'bnW') == line('.')
				\ && !a:fwd
				let s:searchforward = 0
				let cmd = (a:f ? 'F' : 'T')
				call <sid>ColonPattern(<sid>SearchForChar(cmd),
						\ pat, '', a:f, a:fwd)
				return cmd.orig_char
			endif
		endif

		" Check if search would wrap
		if (search(pat, 'nW') == 0 && a:fwd) ||
			\  (search(pat, 'bnW') == 0 && !a:fwd)
			" return ESC
			call <sid>ColonPattern(<sid>SearchForChar(cmd),
					\ pat, '', a:f, a:fwd)
			return s:escape
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
			let pat1  = (a:fwd ? escape(pat, '/') : escape(pat, '?'))
			let res  = cmd.pat1.off."\<cr>"
		else
			" Searching using 't' command
			let cmd  = op_off[0].cmd
			" if match is on previous line the last char, don't add offset
			if !a:fwd
				let pos=searchpos(pat, 'bnW')
				if ((pos[0] < line('.') &&
					\ pos[1] != strlen(substitute(getline(pos[0]), '.', 'X', 'g'))) ||
					\ pos[0] == line('.'))
					let off .= op_off[1]
				else
					let no_offset = 1
				endif
			else
				let off .= op_off[1]
			endif

			let pat1 = (a:fwd ? escape(pat, '/') : escape(pat, '?'))
			let res = cmd.pat1.off."\<cr>"
		endif

		if <sid>CheckSearchWrap(pat, a:fwd, cnt)
			let res = s:escape
		endif
		" handle 'cedit' key gracefully
		let res = substitute(res, &cedit, ''.&cedit, '')

		" save pattern for ';' and ','
		call <sid>ColonPattern(cmd, pat,
				\ off. (no_offset ? op_off[1] : ''), a:f, a:fwd)

		let pat = pat1
		let post_cmd = ''
		" If operator is c, don't switch to normal mode after the
		" command, else we would lose the repeatability using '.'
		" (e.g. cf,foobar<esc> is not repeatable anymore)
		if a:mode != 'o' && v:operator != 'c'
		    if v:operator == 'c'
			    let mode = "\<C-\>\<C-O>"
		    else
			    let mode = "\<C-\>\<C-N>"
		    endif
		    let post_cmd = (a:mode == 'o' ? mode : '').
			    \ ":\<C-U>call histdel('/', -1)\<cr>".
			    \ (a:mode == 'o' ? mode : '').
			    \ ":\<C-U>let @/='". oldsearchpat. "'\<cr>"
		endif

		" For visual mode, the :Ex commands exit the visual selection, so need
		" to reselect it
		call <sid>DebugOutput(res.post_cmd. ((a:mode ==? 'x' && mode() !~ '[vV]') ? 'gv' : ''))
		return res.post_cmd. (a:mode ==? 'x' ? 'gv' : '')
		"return res. ":let @/='".oldsearchpat."'\n"
	finally 
		call <sid>HighlightMatch('', a:fwd)
	endtry
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
189
*ft_improved.txt* - Better f/t command for Vim

Author:  Christian Brabandt <cb@256bit.org>
Version: 0.8 Thu, 27 Mar 2014 23:22:01 +0100

Copyright: (c) 2009-2013 by Christian Brabandt
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
As you type, the matching positions will be highlighted.

To disable either |unlet| that variable, or set it to zero.

If you have enabled it this way, you need to press enter, after having entered
the characters to search for, so that the plugin knows, when not to wait for more
characters and to start searching. Alternatively, if the entered characters
precisely only match one position in the current screen (excluding folds), it
will simply drop you there.

Note: This is highly experimental and basically turns your |f| |F| |t| |T| |,|
|;| keys to use a literal search function.

2.4 Bugs                                             *improvedft-Bugs*
--------

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

0.8: Mar 27, 2014 "{{{1
- handle keys like <Enter>, <Tab> literally
- escape '/' correctly for |t| commands.

0.7: Aug 14, 2013 "{{{1
- small bugfixes
- correctly handle ignorecase setting |improvedft-ignorecase|
- escape '
- make ; work correctly when using backwards motion.

0.6: Mar 16, 2013 "{{{1
- |improvedft-multichars|
- save and restore search-history in all modes correctly

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
