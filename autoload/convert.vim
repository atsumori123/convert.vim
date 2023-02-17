let s:save_cpo = &cpoptions
set cpoptions&vim

"-------------------------------------------------------
" Encord Proc
"-------------------------------------------------------
function! s:CNV_ReOpentEncord(type) abort
		execute 'e ++enc='.a:type
endfunction

function! s:CNV_ConvertEncord(type) abort
		execute 'set fenc='.a:type
endfunction

"-------------------------------------------------------
" NL Proc
"-------------------------------------------------------
function! s:CNV_ReOpenNL(type) abort
		execute 'edit ++fileformat='.a:type
endfunction

function! s:CNV_ConvertNL(type) abort
		execute 'set fileformat='.a:type
endfunction

"*******************************************************
"* Function name: CNV_MenuFilter()
"* Functio	: Filtering when popup-menu is selected
"* Argument	: winid : Winddow ID
"*			  key	: Pressed key
"*******************************************************
function! CNV_MenuFilter(winid, key) abort

	" ---------------------------
	"  When pressed 'l' key
	" ---------------------------
	if a:key == 'l'
		call win_execute(a:winid, 'let w:lnum = line(".")')
		let index = getwinvar(a:winid, 'lnum', 0)
		call popup_close(a:winid, index)
		return 1
	endif

	" --------------------------------------
	"  When pressed shortcut key
	" --------------------------------------
	let index = stridx(s:menu_filter, a:key)
	if index >= 0
		call popup_close(a:winid, index + 1)
		return 1
	endif

	" --------------------------------
	"  Other, pass to normal filter
	" --------------------------------
	return popup_filter_menu(a:winid, a:key)
endfunction

"-------------------------------------------------------
" make popup menu and handler for encord proc
"-------------------------------------------------------
function! CNV_EncordHandler(winid, result)
	let enc_tbl = {1:'sjis', 2:'utf-8'}
	if has_key(enc_tbl, a:result)
		call s:func(enc_tbl[a:result])
	endif
endfunction

function! s:CNV_SelectEncordType() abort
	let menu = []
	call add(menu, " s: sjis")
	call add(menu, " u: utf-8")
	let s:menu_filter = 'suq'

	const winid = popup_create(menu, {
			\ 'border': [1,1,1,1],
			\ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
			\ 'cursorline': 1,
			\ 'wrap': v:false,
			\ 'mapping': v:false,
			\ 'title': ' Encord type ',
			\ 'callback': "CNV_EncordHandler",
			\ 'filter': 'CNV_MenuFilter',
			\ 'filtermode': 'n'
			\ })
	call popup_filter_menu(winid,'k')
endfunction

function! s:CNV_InputEncordType() abort
	echo "\r"
   	let instr = input('Encording type [sjis/utf-8]: ')
   	if empty(instr) | return | endif
   	if instr != "sjis" && instr != "utf-8"
   		echo "\r"
   		echohl WarningMsg | echomsg 'Illegal encord type.' | echohl None
	else
		call s:func(instr)
   	endif
endfunction

"-------------------------------------------------------
" make popup menu and handler for NL proc
"-------------------------------------------------------
function! CNV_NLHandler(winid, result)
	let nl_tbl = {1:'unix', 2:'dos', 3:'mac'}
	if has_key(nl_tbl, a:result)
		call s:func(nl_tbl[a:result])
	endif
endfunction

function! s:CNV_SelectNLType() abort
	let menu = []
	call add(menu, " u: unix (LF)")
	call add(menu, " d: dos (CR+LF)")
	call add(menu, " m: mac (CR)")
	let s:menu_filter = 'udmq'

	const winid = popup_create(menu, {
			\ 'border': [1,1,1,1],
			\ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
			\ 'cursorline': 1,
			\ 'wrap': v:false,
			\ 'mapping': v:false,
			\ 'title': ' NL code ',
			\ 'callback': "CNV_NLHandler",
			\ 'filter': 'CNV_MenuFilter',
			\ 'filtermode': 'n'
			\ })
	call popup_filter_menu(winid,'k')
endfunction

function! s:CNV_InputNLType() abort
	echo "\r"
	let instr = input('NL-code [unix(LF)/dos(CR+LF)/mac(CR)]: ')
   	if empty(instr) | return | endif
   	if instr != "unix" && instr != "dos" && instr != "mac"
   		echo "\r"
   		echohl WarningMsg | echomsg 'Illegal NL-code.' | echohl None
	else
		call s:func(instr)
 	endif
endfunction

"*******************************************************
"* Function name: CNV_Handler()
"* Function	: Handler processing when selected of menu
"* Argument	: winid : Winddow ID
"*		  result: Number of selected item
"*******************************************************
function! CNV_Handler(winid, result)
	if a:result == 2
		"Space --> Tab
		let et = substitute(execute("set expandtab?"), '[ \|\n]', "", "ge")
		execute ':set noexpandtab'
		if s:range
			execute ':'.s:start.','.s:end.'retab!'
		else
			execute ':retab!'
		endif
		execute ':set '.et

	elseif a:result == 3
		"Tab --> Space
		let et = substitute(execute("set expandtab?"), '[ \|\n]', "", "ge")
		execute ':set expandtab'
		if s:range
			execute ':'.s:start.','.s:end.'retab'
		else
			execute ':retab'
		endif
		execute ':set '.et

	elseif a:result == 4
		"Remove spaces and tabs at end of lines
		let pos = getpos(".")
		if s:range
			silent execute ':'.s:start.','.s:end.'s/\s\+$//eg'
		else
			silent execute ':%s/\s\+$//e'
		endif
		call setpos('.', pos)

	elseif a:result == 6
		"Reopen with specified encording
		let s:func = function("s:CNV_ReOpentEncord")
		if s:enable_popup
			call s:CNV_SelectEncordType()
		else
			call s:CNV_InputEncordType()
		endif

	elseif a:result == 7
		"Convert to specified encording
		let s:func = function("s:CNV_ConvertEncord")
		if s:enable_popup
			call s:CNV_SelectEncordType()
		else
			call s:CNV_InputEncordType()
		endif

	elseif a:result == 9
		"Reopen with specified NL-code
		let s:func = function("s:CNV_ReOpenNL")
		if s:enable_popup
			call s:CNV_SelectNLType()
		else
			call s:CNV_InputNLType()
		endif

	elseif a:result == 10
		"Convert to specified NL-code
		let s:func = function("s:CNV_ConvertNL")
		if s:enable_popup
			call s:CNV_SelectNLType()
		else
			call s:CNV_InputNLType()
		endif

	elseif a:result == 11
		"Remove NL-code
		execute '%s/\n//g'

	endif
endfunction

"*******************************************************
"* Function name: CNV_Start()
"* Function	:
"* Argument	: none
"*******************************************************
function! convert#CNV_Start(range, line1, line2) abort
	if a:range
		" get select rage
		let s:range = 1
		let s:start = a:line1
		let s:end = a:line2
	else
		let s:range = 0
		let s:start = ""
		let s:end = ""
	endif

	let s:enable_popup = v:version < 802 ? 0 : 1

	if !s:enable_popup
"		let s:input_cnv_type = function("CNV_input")
		if s:range == 0
			let shortcutkey = {'t':'2', 's':'3', 'r':'4'}
			let key = input("Convert type [t:SP->Tab, s:Tab->SP, r:Remove SP, e:encord, n:NL] ? ")
			if key == "e"
				let shortcutkey = {'r':'6', 'c':'7'}
				let key = input("[r:Reopen, c:Convert] ? ")
			elseif key == "n"
				let shortcutkey = {'r':'9', 'c':'10', 'd':'11'}
				let key = input("[r:Reopen, c:Convert, d:delete] ? ")
			endif
		else
			let shortcutkey = {'t':'2', 's':'3', 'r':'4'}
			let key = input("Convert type [t:SP->Tab, s:Tab->SP, r:Remove] ? ")
		endif
		if has_key(shortcutkey, key)
			call CNV_Handler(0, shortcutkey[key])
		else
			echo "\r"
			echohl WarningMsg | echomsg key.": Invalid operation" | echohl None
		endif
	else
"		let s:input_cnv_type = function("CNV_Select")
		let menu = []
		call add(menu, " [ Tab / Space ]")
		call add(menu, "   t. Space --> Tab (Replace spaces with tabs)")
		call add(menu, "   s. Tab --> Space (Replace tabs with spaces)")
		call add(menu, "   r. Remove spaces and tabs at end of lines")
		let s:menu_filter = '-tsr'
		if s:range == 0
			call add(menu, " [ Encording ]")
			call add(menu, "   1. Reopen with specified encording")
			call add(menu, "   2. Convert to specified encording")
			call add(menu, " [ NL code ]")
			call add(menu, "   3. Reopen with specified NL-code")
			call add(menu, "   4. Convert to specified NL-code")
			call add(menu, "   5. Remove NL-code")
			let s:menu_filter .= '-12-345'
		endif
		let s:menu_filter .= 'q'
		const winid = popup_create(menu, {
				\ 'border': [1,1,1,1],
				\ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
				\ 'cursorline': 1,
				\ 'wrap': v:false,
				\ 'mapping': v:false,
				\ 'title': ' Convert ',
				\ 'callback': "CNV_Handler",
				\ 'filter': 'CNV_MenuFilter',
				\ 'filtermode': 'n'
				\ })
		call popup_filter_menu(winid,'k')
	endif
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
