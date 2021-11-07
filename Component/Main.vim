function Main()
    call s:HiGroups2Buf()
    if bufexists('Tmp_colo2css')
	let l:csssel = ''
	let l:cssrul = []
	let l:fdnlnr = ''
	let l:hiattr = {}
	let l:cssdecl = ''
	let s:is_norm = 1
	for l:grpname in s:init_grp
" Т. к. функция GetLnkGrp работает с регистром "l, то прдеварительно
" подгатавливаем его. Как в вызваемую функцию передавать наименование регистра и
" чтобы она с ним работала именно как с регистром, я так и не победил. Бля, тупею.
	    let @l = ''
	    let l:csssel = s:GetLnkGrp(l:grpname)
	    if !empty(l:csssel) && type(0) != type(l:csssel)
" По‐хорошему, при группировке селекторов, у последнего члена нежелательна запятая
		let l:csssel = substitute(l:csssel, '\(\w\+\)', '\=("." .. submatch(1) .. ",")', 'g')
		call insert(l:cssrul, l:csssel)
	    endif
" Очистим регистр для последующих применений
" А надо ли?
"	    let @l = ''
"	    execute 'normal gg'
	    call cursor(1,1)
	    let l:fndlnr = search('^\<' .. l:grpname .. '\>', 'W', line("$"))
	    if 0 < l:fndlnr
" Смотрим, что корневая группа не ссылается на другую группу, которую мы ещё не
" обработали
		if search('links to ', 'cznW', l:fndlnr) != l:fndlnr 
		    if empty(l:cssrul)
" У этой группы нет ссылающихся на неё других групп
			call insert(l:cssrul, '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)
		    else
			let l:cssrul[0] = '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. ',' .. l:cssrul[0]
		    endif
"		    call s:ParseHiArgs(l:fndlnr)
		    let l:hiattr = s:ParseHiArgs(l:fndlnr)
		    if !empty(l:hiattr) && type(0) != type(l:hiattr)
			let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
			if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
			    let l:cssrul += l:cssdecl
			    call add(s:css_entries, l:cssrul)
			endif
		    endif
" Всё одно удаляем строку с этой группой, даже если мы не смогли получить её
" свойства и если она не ссылается на другие группы
		    execute l:fndlnr'delete'
		endif
	    endif
" Группа «Normal» может быть только одна, обнуляем этот признак после первого (и
" всех последующих) проходов цикла
	let s:is_norm = 0
	endfor
    endif
"echo s:css_rule
echo s:css_entries
endfunction

