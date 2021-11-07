



let s:init_grp = ['Normal', 'ColorColumn', 'Conceal', 'Cursor', 'CursorColumn',
    \ 'CursorIM', 'CursorLine', 'CursorLineNr', 'DiffAdd', 'DiffChange',
    \ 'DiffDelete', 'DiffText', 'Directory', 'EndOfBuffer', 'ErrorMsg',
    \ 'FoldColumn', 'Folded', 'IncSearch', 'LineNr', 'LineNrAbove',
    \ 'LineNrBelow', 'MatchParen', 'ModeMsg', 'MoreMsg', 'NonText', 'Pmenu',
    \ 'PmenuSbar', 'PmenuSel', 'PmenuThumb', 'Question', 'QuickFixLine',
    \ 'Search', 'SignColumn', 'SpecialKey', 'SpellBad', 'SpellCap', 'SpellLocal',
    \ 'SpellRare', 'StatusLine', 'StatusLineNC', 'StatusLineTerm',
    \ 'StatusLineTermNC', 'TabLine', 'TabLineFill', 'TabLineSel', 'Terminal',
    \ 'Title', 'VertSplit', 'Visual', 'VisualNOS', 'WarningMsg', 'WildMenu',
    \ 'lCursor']


function s:GetEntry(bnr, lnr, colnr, offset, motion)
    let @e = ""
    if !setpos('.', [a:bnr, a:lnr, a:colnr, a:offset])
	execute 'normal "ey' .. a:motion
    endif
    return getreg('e')
endfunction



function s:GetLnkGrp(grpname)
    if !empty(a:grpname)
"	let @l = ""
	if !cursor(1,1)
	    let l:srchpat = 'links to\s\+' .. a:grpname .. '$'
	    let l:srchflgs = 'W'
	    let l:lnkgrpnm = ""
	    let l:lnr = 1
	    while l:lnr
		let l:fndlnr = search(l:srchpat, l:srchflgs, line('$'))
		if l:fndlnr
		    let l:lnkgrpnm = s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
		    if !empty(l:lnkgrpnm)
			let @L = ' ' .. l:lnkgrpnm 
		    endif
		    execute l:fndlnr'delete'
" Могут быть группы, которые ссылаются на эту группу, которая ссылается на
" на начальную группу
		    call s:GetLnkGrp(l:lnkgrpnm)
		endif
	    let l:lnr = l:fndlnr
	    endwhile
"	return split(getreg('L'))
"	let @l = ''
	return @L
	endif
    endif
    return -1
endfunction



function s:HiGrpNm2CssSel(grpname)
    if !empty(a:grpname)
	let l:csssel = ''
" Т. к. функция GetLnkGrp работает с регистром "l, то предварительно
" подгатавливаем его. Как в вызваемую функцию передавать наименование регистра и
" чтобы она с ним работала именно как с регистром, я так и не победил. Бля, тупею.
	let @l = ''
	let l:csssel = s:GetLnkGrp(a:grpname)
	if !empty(l:csssel) && type(0) != type(l:csssel)
" По‐хорошему, при группировании селекторов, у последнего члена нежелательна
" запятая. Поэтому, чтобы не городить проверки, в конце делаем финт ушами
"	    let l:csssel = substitute(l:csssel, '\(\w\+\)', '\+("." .. submatch(1) .. ",")' , 'g')
	    let l:csssel = substitute(l:csssel, '\(\w\+\)', '.\1,', 'g')
	endif
"	call cursor(1,1)
	call setpos('.', [0, 1, 1, 0])
	let l:fndlnr = search('^\<' .. a:grpname .. '\>', 'cW', line('$'))
	if 0 < l:fndlnr
" Смотрим, что группа не ссылается на другую группу, которую мы ещё не обработали
	    if search('links to ', 'cnW', l:fndlnr) != l:fndlnr
		if empty(l:csssel)
		    let l:csssel = '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
		elseif type(0) != type(l:csssel)
		    let l:csssel = '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. ',' .. l:csssel
		endif
		let l:csssel = s:is_norm ? trim('*, ' .. l:csssel, ',', 2) : trim(l:csssel, ',', 2)
" Нда, вначале добавляем запятые а потом удаляем... Но так быстрее.
		let l:csssel = trim(l:csssel, ',', 2)
		return l:csssel
	    endif
	endif
    endif
	return -1
endfunction

function TestMain()
    for l:defgrp in s:init_grp
	echo 'defgroup ' l:defgrp
	call s:HiGrpNm2CssSel(l:defgrp)
    endfor
endfunction


