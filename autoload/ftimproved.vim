" ftimproved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.6
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Sat, 16 Mar 2013 14:59:42 +0100
"
" Script: 
" Copyright:   (c) 2009 - 2013  by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3877 6 :AutoInstall: ft_improved.vim
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
	if a:char =~ '[ft]'
		return '/'
	else
		return '?'
	endif
endfun

fun! <sid>EscapePat(pat, vmagic) "{{{1
	return (a:vmagic ? '\V' : '').escape(a:pat, '\')
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

fun! <sid>HighlightMatch(char, dir) "{{{1
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
			let pat = '\%('. pat. '\m\)\ze\&\%<'.(line('w$')+1).'l'
		else
			let pat = '\%(\%<'. col('.'). 'c\&\%'. line('.'). 'l'
			let pat .= '\|\%<'. line('.'). 'l\)'. a:char
			" Make sure, it only matches within the current viewport
			let pat = '\%('. pat. '\m\)\ze\&\%>'.(line('w0')-1).'l'
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
	try
		let char = nr2char(getchar())
		if  char == s:escape
			" abort when Escape has been hit
			return char
		elseif empty(char) || char ==? "\x80\xFD\x60" "CursorHoldEvent"
			return s:escape
		endif
		let char  = <sid>EscapePat(char, 1)
		" ignore case of pattern? Does only work with search, not with original
		" f/F/t/T commands
		if !get(g:, "ft_improved_ignorecase", 0)
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
			let res = cmd.pat1.off."\<cr>"
		endif

		if <sid>CheckSearchWrap(pat, a:fwd, cnt)
			let res = s:escape
		endif
		" handle 'cedit' key gracefully
		let res = substitute(res, &cedit, ''.&cedit, '')

		" save pattern for ';' and ','
		call <sid>ColonPattern(cmd, pat,
				\ off. (no_offset ? op_off[1] : ''), a:f)

		let pat = pat1
		call <sid>DebugOutput(res)
		if v:operator == 'c'
			let mode = "\<C-\>\<C-O>"
		else
			let mode = "\<C-\>\<C-N>"
		endif
		let post_cmd = (a:mode == 'o' ? mode : '').
			\ ":call histdel('/', -1)\<cr>".
			\ (a:mode == 'o' ? mode : '').
			\ ":let @/='". oldsearchpat. "'\<cr>"

		" for operator-pending mappings, don't return the post_cmd, it could
		" end up in insert mode
		return res.post_cmd
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
