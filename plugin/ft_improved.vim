" ft_improved.vim - Better f/t command for Vim
" -------------------------------------------------------------
" Version:	   0.9
" Maintainer:  Christian Brabandt <cb@256bit.org>
" Last Change: Thu, 15 Jan 2015 21:40:10 +0100
"
" Script: 
" Copyright:   (c) 2009, 2010, 2011, 2012  by Christian Brabandt
"			   The VIM LICENSE applies to histwin.vim 
"			   (see |copyright|) except use "ft_improved.vim" 
"			   instead of "Vim".
"			   No warranty, express or implied.
"	 *** ***   Use At-Your-Own-Risk!   *** ***
" GetLatestVimScripts: 3877 9 :AutoInstall: ft_improved.vim
"
" Init: {{{1
let s:cpo= &cpo
if exists("g:loaded_ft_improved") || &cp
  finish
endif
set cpo&vim
let g:loaded_ft_improved = 1

fun! <sid>DoNotRemap(key, mode) "{{{1
    if !empty(maparg(a:key, a:mode, 0))
        return 1
    endif
	if a:key ==? ','
		return get(g:, 'ft_improved_nomap_comma', 0)
	elseif a:key ==? ';'
		return get(g:, 'ft_improved_nomap_semicolon', 0)
	else
		return get(g:, 'ft_improved_nomap_'.a:key, 0)
	endif
endfu
fun! <sid>Map(lhs, rhs) "{{{1
    for mode in split('nxo', '\zs')
        if hasmapto(a:rhs, mode) || <sid>DoNotRemap(a:lhs, mode)
            continue
        endif
        exe mode. "noremap <silent> <expr> <unique>" a:lhs
                \ substitute(a:rhs, 'X', '"'.mode.'"', '')
    endfor
endfun
fun! <sid>Unmap(lhs) "{{{1
	if !empty(maparg(a:lhs, 'nov'))
		exe "nunmap" a:lhs
		exe "xunmap" a:lhs
		exe "ounmap" a:lhs
	endif
endfun
fun! <sid>Activate(enable) "{{{1
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

com! DisableImprovedFT :call <sid>Activate(0)
com! EnableImprovedFT  :call <sid>Activate(1)

call <sid>Activate(1)

" Restore: "{{{1
let &cpo=s:cpo
unlet s:cpo
" vim: ts=4 sts=4 fdm=marker com+=l\:\"
