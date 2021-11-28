






let s:hi_args = ['gui', 'guifg', 'guibg', 'guisp', 'font']

let s:spec_attr = [['bold', 'wght'], ['italic', 'itlc'],
    \ ['underline', 'undlne'], ['undercurl', 'undcrl'],
    \ ['reverse', 'rvrs'], ['inverse', 'rvrs'],
    \ ['strikethrough', 'skthro'], ['NONE', 'rset'],
    \ ['standout', 'lum'], ['nocombine', 'ncomb']]

let s:fnt_size = ['h', 'w', 'W']




function ParseHiArgs(lnr)
    if !empty(a:lnr)
	let l:hiattr = {}
	let l:str = getline(a:lnr)
	for l:hiarg in s:hi_args
	    let @s = ''
	    if 'gui' == l:hiarg
		let l:pos = matchend(l:str, l:hiarg .. '=')
		if 0 <= l:pos
" Если присутствует в строке, копируем значение как СЛОВО до пробельного символа
		    let @s = s:GetEntry(0, a:lnr, l:pos+1, 0, 'E')
		    let l:idx = 0
		    while !empty(@s)
			if 0 <= stridx(@s, s:spec_attr[l:idx][0])
" При наличии наименования аттрибута из массива, присваиваем значение
" соответствующему наименованию ключа словаря
			    let l:hiattr[s:spec_attr[l:idx][1]] = 1
" и удаляем из строки наименование аттрибута
			    let @s = substitute(
				\ @s, s:spec_attr[l:idx][0]..'\%(,\|\s\)\=', '', '')
			endif
			let l:idx += 1
		    endwhile
		endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
	continue
	    elseif 'guifg' == l:hiarg || 'guibg' == l:hiarg || 'guisp' == l:hiarg
		let l:pos = matchend(l:str, l:hiarg .. '=')
		if 0 <= l:pos
" НАДО: сделать копирование подстроки, включая пробелы
		    let @s = s:GetEntry(0, a:lnr, l:pos+1, 0, 'E')
		    if !empty(@s)
			let @s = s:GetColor(@s)
			if !empty(@s) && 0 <= @s
			    if 'guifg' == l:hiarg
				let l:hiattr['fgco'] = getreg('s')
			    elseif 'guibg' == l:hiarg
				let l:hiattr['bgco'] = getreg('s')
			    elseif 'guisp' == l:hiarg
				let l:hiattr['spco'] = getreg('s')
			    endif
			endif
		    endif
		endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
	continue
	    elseif 'font' == l:hiarg
		let l:pos = matchend(l:str, l:hiarg .. '=')
		if 0 <= l:pos
" Копируем до конца строки, т. к. я надеюсь, что аргумент font будет всегда
" последним в строке свойств группы
		    let @s = s:GetEntry(0, a:lnr, l:pos+1, 0, 'g_')
		elseif s:is_norm
			let @s = getfontname()
			if empty(@s)
			    let @s = &guifont
			    if !empty(@s)
" Шаблон поиска не очень хороший
				let l:com = match(@s, '\w,')
				if 0 < l:com
				    let @s = strpart(@s, 0, l:com)
				endif
			    endif
			endif
		endif
		if !empty(@s)
		    let l:fnt = s:ParseFont(@s)
		    if !empty(l:fnt) && type(0) != type(l:fnt)
			let l:hiattr['font'] = l:fnt
		    endif
		endif
	    endif
	endfor
	return l:hiattr
    endif
    return -1
echo l:hiattr

endfunction



"	    elseif 'font' == l:hiarg
"		echo 'iam in font'
"		let l:pos = matchend(l:str, l:hiarg .. '=')
"		if 0 <= l:pos
" Копируем до конца строки, т. к. я надеюсь, что аргумент font будет всегда
" последним в строке свойств группы
"		    let @s = s:GetEntry(0, a:lnr, l:pos+1, 0, 'g_')
"		    if !empty(@s)
"			let l:fnt = s:ParseFont(@s)
"			if !empty(l:fnt) && type(0) != type(l:fnt)
"			    let l:hiattr['font'] = l:fnt
"			endif
"		    endif
"		endif
"	    else
"		echo 'aim alter font'
"		if 1
"		    let @s = getfontname()
"		    echo @s
"		    if empty(@s)
"			let @s = &gui
"			echo @s
"			if !empty(@s)
"" Пробел после запятой важен
"			    l:cma = stridx(getreg('s'), ', ')
" Шаблон поиска не очень хороший
"			    l:com = match(@s, '\w,')
"			    if 0 < l:com
"				let @s = strpart(@s, 0, l:com)
"			    endif
"			endif
"		    endif
"		    let l:fnt = s:ParseFont(@s)
"		    if !empty(l:fnt) && type(0) != type(l:fnt)
"			let l:hiattr['font'] = l:fnt
"		    endif
"		endif
"	    endif


"while !empty(@s)
"    for attr in s:spec_attr
"	if 0 <=(stridx(@s, attr[0]))
"	    let l:hiattr[attr[1]] = 1
"	    let @s = substitute(@s, '\c'..attr[0]..'\%(\s\|,\)\=', '', '')
"	endif
"    endfor
"endwhile


"let l:idx = 0
"while !empty(@s)
"    if 0 <= (stridx(@s, s:spec_attr[l:idx][0]))
"	let l:hiattr[s:spec_attr[l:idx][1]] = 1
"	let @s = substitute(@s, s:spec_attr[l:idx][0]..'\%(,\|\s\)\=', '', '')
"    endif
"    let l:idx += 1
"endwhile



"if !empty(a:lnr)
"    let l:hiattr = {}
"    let l:str = getline(a:lnr)
"    for l:hiarg in s:hi_args
"	let @s = ''
"	let l:pos = matchend(l:str, l:hiarg .. '=')
"	if 0 <= l:pos
"	    if 'gui' == l:hiarg
"		let @s = s:GetEntry(0, a:lnr, l:pos+1, 0, 'E')
"		let l:idx = 0
"		while !empty(@s)
"		    if 0 <= (stridx(@s, s:spec_attr[l:idx][0]))
"			let l:hiattr[s:spec_attr[l:idx][1]] = 1
"			let @s = substitute(@s, s:spec_attr[l:idx][0]..'\%(,\|\s\)\=', '', '')
"		    endif
"		    let l:idx += 1
"		endwhile
"	    endif
"	    elseif 'guifg' == l:hiarg || 'guibg' == l:hiarg || 'guisp' == l:hiarg
"		if





"unlet s:hi_attr
