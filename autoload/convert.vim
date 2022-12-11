let s:save_cpo = &cpoptions
set cpoptions&vim

"-------------------------------------------------------
" s:Main_menu()
"-------------------------------------------------------
function! s:Main_menu(n)
	if a:n == 2
		"Space --> Tab
		close
		let et = substitute(execute("set expandtab?"), '[ \|\n]', "", "ge")
		execute ':set noexpandtab'
		if s:range
			execute ':'.s:start.','.s:end.'retab!'
		else
			execute ':retab!'
		endif
		execute ':set '.et

	elseif a:n == 3
		"Tab --> Space
		close
		let et = substitute(execute("set expandtab?"), '[ \|\n]', "", "ge")
		execute ':set expandtab'
		if s:range
			execute ':'.s:start.','.s:end.'retab'
		else
			execute ':retab'
		endif
		execute ':set '.et
		
	elseif a:n == 4
		"Remove spaces and tabs at end of lines
		close
		let pos = getpos(".")
		if s:range
			silent execute ':'.s:start.','.s:end.'s/\s\+$//eg'
		else
			echo "abc"
			silent execute ':%s/\s\+$//e'
		endif
		call setpos('.', pos)

	elseif a:n == 6
		"Reopen with specified encording
		call s:Redraw_floating_window('MENU_ENC_REOPEN')

	elseif a:n == 7
		"Convert to specified encording
		call s:Redraw_floating_window('MENU_ENC_CNV')

	elseif a:n == 9
		"Reopen with specified NL-code
		call s:Redraw_floating_window('MENU_NL_REOPEN')

	elseif a:n == 10
		"Convert to specified NL-code
		call s:Redraw_floating_window('MENU_NL_CNV')

	elseif a:n == 11
		"Remove NL-code
		close
		execute '%s/\n//g'
	endif

endfunction

"-------------------------------------------------------
" s:Move_parent()
"-------------------------------------------------------
function! s:Move_parent()
	echo s:menu_hierarchy
	call remove(s:menu_hierarchy, -1)

	if len(s:menu_hierarchy) == 0
		close
	else
		let menu_id = remove(s:menu_hierarchy, -1)
		call s:Redraw_floating_window(menu_id)
	endif
endfunction

"-------------------------------------------------------
" s:Encord_reopen()
"-------------------------------------------------------
function! s:Encord_reopen(n)
	close
	let type = a:n == 2 ? "sjis" : "utf-8"	
	execute 'e ++enc='.type
endfunction

"-------------------------------------------------------
" s:Encord_convert()
"-------------------------------------------------------
function! s:Encord_convert(n)
	close
	let type = a:n == 2 ? "sjis" : "utf-8"	
	execute 'set fenc='.type
endfunction

"-------------------------------------------------------
" s:NL_reopen()
"-------------------------------------------------------
function! s:NL_reopen(n)
	close
	if a:n == 2
		let type = "unix"
	elseif a:n == 3
		let type = "dos"
	else
		let type = "mac"
	endif
	execute 'edit ++fileformat='.type
endfunction	

"-------------------------------------------------------
" s:NL_convert()
"-------------------------------------------------------
function! s:NL_convert(n)
	close
	if a:n == 2
		let type = "unix"
	elseif a:n == 3
		let type = "dos"
	else
		let type = "mac"
	endif
	execute 'set fileformat='.type
endfunction

"-------------------------------------------------------
" s:Selected_handler()
"-------------------------------------------------------
function! s:Selected_handler()
	if empty(s:exe_handler)
		return
	endif

	let s:func = function(s:exe_handler)
	call s:func(line("."))
endfunction

"-------------------------------------------------------
" s:Make_menu()
"-------------------------------------------------------
function! s:Make_menu(menu_id)
	let menu = []

	if a:menu_id == "MENU_MAIN"
		call add(menu, " [ Tab / Space ]")
		call add(menu, "   Space --> Tab (Replace spaces with tabs)")
		call add(menu, "   Tab --> Space (Replace tabs with spaces)")
		call add(menu, "   Remove spaces and tabs at end of lines")
		if s:range == 0
			call add(menu, " [ Encording ]")
			call add(menu, "   Reopen with specified encording")
			call add(menu, "   Convert to specified encording")
			call add(menu, " [ NL code ]")
			call add(menu, "   Reopen with specified NL-code")
			call add(menu, "   Convert to specified NL-code")
			call add(menu, "   Remove NL-code")
		endif
		let s:exe_handler= "s:Main_menu"
		call add(s:menu_hierarchy, a:menu_id)

	elseif a:menu_id == "MENU_ENC_REOPEN"
		call add(menu, " [ Re.open encord type ]")
		call add(menu, "   sjis")
		call add(menu, "   utf-8")
		let s:exe_handler = "s:Encord_reopen"
		call add(s:menu_hierarchy, a:menu_id)

	elseif a:menu_id == "MENU_ENC_CNV"
		call add(menu, " [ Convert encord type ]")
		call add(menu, "   sjis")
		call add(menu, "   utf-8")
		let s:exe_handler = "s:Encord_convert"
		call add(s:menu_hierarchy, a:menu_id)

	elseif a:menu_id == "MENU_NL_REOPEN"
		call add(menu, " [ Re.open NL code ]")
		call add(menu, "   unix (LF)")
		call add(menu, "   dos (CR+LF)")
		call add(menu, "   mac (CR)")
		let s:exe_handler = "s:NL_reopen"
		call add(s:menu_hierarchy, a:menu_id)

	elseif a:menu_id == "MENU_NL_CNV"
		call add(menu, " [ Convert NL code ]")
		call add(menu, "   unix (LF)")
		call add(menu, "   dos (CR+LF)")
		call add(menu, "   mac (CR)")
		let s:exe_handler = "s:NL_convert"
		call add(s:menu_hierarchy, a:menu_id)
	endif

	return menu
endfunction

"-------------------------------------------------------
" s:Open_floating_window()
"-------------------------------------------------------
function! s:Open_floating_window(menu_id)
	let menu = s:Make_menu(a:menu_id)

	let winnum = bufwinnr('-convert-')
	if winnum != -1
		" Already in the window, jump to it
		exe winnum.'wincmd w'
		return
	else
		" open floating window
		let win_id = nvim_open_win(bufnr('%'), v:true, {
			\   'width': 50,
			\   'height': len(menu),
			\   'relative': 'cursor',
			\   'anchor': "NW",
			\   'row': 1,
			\   'col': 0,
			\   'external': v:false,
			\})
	
		" draw to new buffer
		enew
		file `= '-convert-'`
	endif

	setlocal modifiable
	call setline('.', menu)

	setlocal buftype=nofile
	setlocal bufhidden=delete
	setlocal noswapfile
	setlocal nowrap
	setlocal nonumber

	nnoremap <buffer> <silent> <CR> :call <SID>Selected_handler()<CR>
	nnoremap <buffer> <silent> l :call <SID>Selected_handler()<CR>
	nnoremap <buffer> <silent> h :call <SID>Move_parent()<CR>
	nnoremap <buffer> <silent> q :close<CR>

	highlight MyNormal guibg=#404040
	set winhighlight=Normal:MyNormal

	setlocal nomodifiable
endfunction

"-------------------------------------------------------
" s:Redraw_floating_window()
"-------------------------------------------------------
function! s:Redraw_floating_window(menu_id)
	let menu = s:Make_menu(a:menu_id)

	setlocal modifiable
	silent! %delete _
	call setline('.', menu)
	setlocal nomodifiable
endfunction

"-------------------------------------------------------
" s:Start_convert()
"-------------------------------------------------------
function! convert#Start_convert(range, line1, line2) abort
	echo a:range
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

	let s:menu_hierarchy = []
	call s:Open_floating_window('MENU_MAIN')
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo

