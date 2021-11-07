
"{'bg': '#282828', 'undlne': 1, 'wght': 1, 'itlc': 1, 'font': {'fntbold': 1, 'fnthght': '9', 'fntname': 'JetBrains Mono', 'fntwght': '350', 'fntitlc': 1, 'fntwdth': '8.5', 'fntsout': 1, 'fntundr': 1}, 'undcrl': 1, 'decolo': '#83a598', 'color': '#ebdbb2'}
"
"{'bg': '#282828', 'font': {'fnthght': '9', 'fntname': 'JetBrains Mono'}, 'color': '#ebdbb2'} 
"
"{'bg': '#282828', 'undlne': 1, 'wght': 1, 'itlc': 1, 'font': {'fntbold': 1, 'fnthght': '9', 'fntname': 'JetBrains Mono', 'fntwght': '350', 'fntitlc': 1, 'fntwdth': '8.5', 'fntsout': 1, 'fntundr': 1}, 'color': '#ebdbb2', 'decolo': '#83a598'}
"{'bg': '#282828', 'wght': 1, 'rvrs': 1, 'color': '#fb4934'}
let s:is_norm = 0
let s:css_decl = []
let s:bg_norm = '#282828'
let s:fg_norm = '#ebdbb2'

"{'bg': '#282828', 'wght': 1, 'rvrs': 1, 'color': '#fb4934'}

function HiAttr2CssDecl(hiattr)
    if !empty(a:hiattr)
	let l:cssdecl = []
	let l:fnt = {}
	if has_key(a:hiattr, 'font')
	    let l:fnt = a:hiattr['font']
	endif
"	if !has_key(a:hiattr, 'font') && s:is_norm
"	    let l:fnt = s:ParseFont(getfontname())
"	    if !empty(l:fnt) && type(0) == type(l:fnt)
"		return -1
"	    endif
"	elseif has_key(a:hiattr, 'font')
"	    let l:fnt = a:hiattr['font']
"	endif

	if !empty(l:fnt)
" Формируем объявление (декларацию) для шрифта
	    if has_key(l:fnt, 'fntname')
		call add(l:cssdecl, 'font-family: "' .. l:fnt['fntname']
		    \ .. '", monospace;')
	    endif
	    if has_key(l:fnt, 'fnthght')
" Для X11 делим на десять. Едининцы измерения устаналвиаем в пункты (points), как
" указано для шрифта в справке Vim
		call add(l:cssdecl, 'font-size: ' .. (has('X11') ?
		    \ l:fnt['fnthght']/10 : l:fnt['fnthght']) .. 'pt;')
	    endif
	    if has_key(l:fnt, 'fntwdt')
" НАДО: составить какую‐то таблиц соответсвий для свойств, определённых для X11
" и ключевых слов, определённых в CSS. Не все свойства X11 совпадают с CSS
" НАДО: посмотреть, как Windows высчитывает ширину символов и как это
" соотносится с CSS
		if has('X11')
		    call add(l:cssdecl, 'font-stretch: '
			\ .. (tr(l:fnt['fntwdt'], ' ', '-')) .. ';')
		endif
	    endif
	    if has_key(l:fnt, 'fntwght')
" Старые «Иа» не очень поддерживали числовые значения для насыщенности (жирности)
" шрифтов, но, всё же, оставим это
		call add(l:cssdecl, 'font-weight: ' .. l:fnt['fntwght'] .. ';')
	    endif
	    if get(l:fnt, 'fntbold')
" На всякий случай. Пересекаться не должны, но...
		let l:idx = match(l:cssdecl, 'font-weight')
		if 0 <= l:idx
		    let l:cssdecl[l:idx] = 'font-weight: bold;'
		else
		    call add(l:cssdecl, 'font-weight: bold;') 
		endif
	    endif
	    if get(l:fnt, 'fntitlc')
		call add(l:cssdecl, 'font-style: italic;')
	    endif
	elseif s:is_norm
	    call add(l:cssdecl, 'font-family: monospace;')
	endif

	if get(a:hiattr, 'wght')
" Хотя... если в Windows задать это свойство обеими способами, то возвращает
" только одно из них
	    let l:idx = match(l:cssdecl, 'font-weight')
	    if 0 <= l:idx
		if 0 > match(l:cssdecl[l:idx], 'bold')
		    let l:cssdecl[l:idx] = 'font-weight: bold;'
		endif
	    else
		call add(l:cssdecl, 'font-weight: bold;')
	    endif
	endif

	if get(a:hiattr, 'itlc')
" Аналогично предыдущему с насыщенностью, но лучше пока оставим. Черевато
" потерей производительности
	    let l:idx = match(l:cssdecl, 'font-style:')
	    if 0 <= l:idx
		if 0 > match(l:cssdecl[l:idx], 'italic')
		    let l:cssdecl[l:idx] = 'font-style: italic;'
		endif
	    else
		call add(l:cssdecl, 'font-style: italic;')
	    endif
	endif

" Формируем объявление (декларацию) для цвета заднего и переднего плана
	if has_key(a:hiattr, 'bgco')
	    let l:bgc = get(a:hiattr, 'bgco')
	    if 'NONE' ==? l:bgc && !s:is_norm
"	    let l:idx = match(l:cssdecl, 'backround-color')
"	    if 0 <= l:idx
"		let l:cssdecl[l:idc] = 'background-color: transparent;'
"	    else
		    call add(l:cssdecl, 'background-color: transparent;')
"	    endif
	    elseif 'bg' ==? l:bgc && !s:is_norm
		if '' != s:bg_norm
"		let l:idx = match(l:cssdecl, 'background-color')
"		if 0 <=l:idx
"		    let l:cssdecl[l:idx] = 'background-color: ' .. s:bg_norm
"		else
		    call add(l:cssdecl, 'background-color: ' ..s:bg_norm.. ';')
"		endif
		else
		    return -1
		endif
	    elseif 'fg' ==? l:bgc && !s:is_norm
		if '' != s:fg_norm
"		let l:idx = match(l:cssdecl, 'background-color')
"		if 0 <=l:idx
"		    let l:cssdecl[l:idx] = 'background-color: ' .. s:fg_norm
"		else
		    call add(l:cssdecl, 'background-color: ' ..s:fg_norm.. ';')
"		endif
		else
		    return -1
		endif
	    else
		call add(l:cssdecl, 'background-color: ' .. l:bgc .. ';')
" Так называемый «побочный эффект» этой функции, т. к. она изменяет состояние
" глобальной по отношению к ней переменной, но так проще, поэтому оставлю
" Это как‐то неуклюже получилось, но что‐то другое в одну строку не придумал
		let s:bg_norm = s:is_norm ? l:bgc : s:bg_norm
	    endif
" На случай, если для группы «Normal» не определены эти значения
	elseif is_norm
	    call add(l:cssdecl, 'background-color: transparent;')
" НАДО: посмотреть, как в Vim это реализовано. Прикинуть, как вытаскивать
" системные значения. Для Windows я примерно представляю, а вот в других не очень
	    let s:bg_norm = '#FFFFFF'
	endif

	if has_key(a:hiattr, 'fgco')
" Чтобы каждый раз не дёргать эту функцию
	    let l:fgc = get(a:hiattr, 'fgco')
	    if 'NONE' ==? l:fgc && !s:is_norm
"		let l:idx = match(l:cssdecl, '\<color')
"		if 0 <= l:idx
"		    let l:cssdecl[l:idx] = 'color: inherit;'
"		else
		    call add(l:cssdecl, 'color: inherit;')
"		endif
	    elseif 'bg' ==? l:fgc && !s:is_norm
		if '' != s:bg_norm
"		    let l:idx = match(l:cssdecl, '\<color')
"		    if 0 <= l:idx
"			let l:cssdecl[l:idx] = 'color: ' .. s:bg_norm .. ';'
"		    else
			call add(l:cssdecl, 'color: ' .. s:bg_norm .. ';')
"		    endif
		else
		    return -1
		endif
	    elseif 'fg' ==? l:fgc && !s:is_norm
		if '' != s:fg_norm
"		    let l:idx = match(l:cssdecl, '\<color')
"		    if 0 <= l:idx
"			let l:cssdecl[l:idx] = 'color: ' .. s:fg_norm .. ';'
"		    else
			call add(l:cssdecl, 'color: ' .. s:fg_norm .. ';')
"		    endif
		else
		    return -1
		endif
	    else
		call add(l:cssdecl, 'color: ' .. l:fgc .. ';')
" Так называемый «побочный эффект» этой функции, т. к. она изменяет состояние
" глобальной по отношению к ней переменной, но так проще, поэтому оставлю
" Это как‐то неуклюже получилось, но что‐то другое в одну строку не придумал
		let s:fg_norm = s:is_norm ? l:fgc : s:fg_norm
	    endif
" На случай, если для группы «Normal» не определены эти значения
	elseif is_norm
	    call add(l:cssdecl, 'color: inherit;')
" НАДО: посмотреть, как в Vim это реализовано. Прикинуть, как вытаскивать
" системные значения. Для Windows я примерно представляю, а вот в других не очень
	    let s:fg_norm = '#000000'
	endif

	if !empty(l:fnt)
	    if get(l:fnt, 'fntundr')
"		let l:idx = match(l:cssdecl, 'text-decoration')
"		if 0 <= l:idx
"		    let l:cssdecl[l:idx] =
"			\ trim(l:cssdecl[l:idx], ';', 2) .. ' underline;'
"		else
		    call add(l:cssdecl, 'text-decoration: underline;')
"		endif
	    endif
	    if get(l:fnt, 'fntsout')
		let l:idx = match(l:cssdecl, 'text-decoration')
		if 0 <= l:idx
		    let l:cssdecl[l:idx] =
			\ trim(l:cssdecl[l:idx], ';', 2) .. ' line-throught;'
		else
		    call add(l:cssdecl, 'text-decoration: line-throught;')
		endif
	    endif
	endif

	if get(a:hiattr, 'undlne') && !s:is_norm
" Тоже, что и рашьше. В Windows, как правило, только одно свойство возвращается
	    let l:idx = match(l:cssdecl, 'text-decoration')
	    if 0 <= l:idx
		if 0 > match(l:cssdecl[l:idx], 'underline')
		    let l:cssdecl[l:idx] =
			\ trim(l:cssdecl[l:idx], ';', 2) .. ' underline;'
		endif
	    else
		call add(l:cssdecl, 'text-decoration: underline;')
	    endif
	endif

	if get(a:hiattr, 'skthro') && !s:is_norm
" Аналогично
	    let l:idx = match(l:cssdecl, 'text-decoration')
	    if 0 <= l:idx
		if 0 > match(l:cssdecl[l:idx], 'line-throught')
		    let l:cssdecl[l:idx] =
			\ trim(l:cssdecl[l:idx], ';', 2) .. ' line-throught;'
		endif
	    else
		call add(l:cssdecl, 'text-decoration: line-throught;')
	    endif
	endif

	if get(a:hiattr, 'undcrl') && !s:is_norm
" Эта декларация старыми «осликами» и проч. не поддерживается, как я помню.
" Поэтому первой записью будет просто text-decoration
	    call add(l:cssdecl,
		\ 'text-decoration: underline;'
		\ .. ' -moz-text-decoration-line: underline; -moz-text-decoration-style: wavy;'
		\ .. ' -webkit-text-decoration-line: underline; -webkit-text-decoration-style: wavy;'
		\ .. ' text-decoration-line: underline; text-decoration-style: wavy;')
	endif

	if has_key(a:hiattr, 'spco') && !s:is_norm
	    let l:tdc = get(a:hiattr, 'spco')
" Тоже и с этим объявлением и поддержикой ранними обозревателями страниц Интернета
	    if 'NONE' ==? l:tdc
		call add(l:cssdecl, '-moz-text-decoration-color: currentColor;'
		    \ .. ' -webkit-text-decoration-color: currentColor;'
		    \ .. ' text-decoration-color: currentColor;')
	    elseif 'bg' ==? l:tdc
		if '' != s:bg_norm
		    call add(l:cssdecl,
			\ '-moz-text-decoration-color: ' .. s:bg_norm .. ';'
			\ .. ' -webkit-text-decoration-color: ' .. s:bg_norm .. ';'
			\ .. ' text-decoration-color: ' .. s:bg_norm .. ';')
		else
		    return -1
		endif
	    elseif 'fg' ==? l:tdc
		if '' != s:fg_norm
		    call add(l:cssdecl,
			\ '-moz-text-decoration-color: ' .. s:fg_norm .. ';'
			\ .. ' -webkit-text-decoration-color: ' .. s:fg_norm .. ';'
			\ .. ' text-decoration-color: ' .. s:fg_norm .. ';')
		else
		    return -1
		endif
	    else
		call add(l:cssdecl, '-moz-text-decoration-color: ' .. l:tdc .. ';'
		    \ .. ' -webkit-text-decoration-color: ' .. l:tdc .. ';'
		    \ .. ' text-decoration-color: ' .. l:tdc .. ';')
	    endif
	endif

	if get(a:hiattr, 'rvrs') && !s:is_norm
	    if '' != s:fg_norm && '' != s:bg_norm
		let @i = ''
		let @f = ''
		let @x = ''
		let @b = ''
		let l:idx = match(l:cssdecl, '\<color')
		if 0 <= l:idx
" Если цвет переднего плана определён ранее, то сохраняем его индекс объялвения
" и значение
		    let @i = l:idx
		    let @f = matchstr(l:cssdecl[l:idx], '#\w\+')
		endif
		let l:idx = match(l:cssdecl, 'background-color')
		if 0 <= l:idx
" И для цвета заднего плана
		    let @x = l:idx
		    let @b = matchstr(l:cssdecl[l:idx], '#\w\+')
		endif
		if '' != @i && '' != @x
" Если и то, и то задано, то тупо меняем их местами
		    let l:cssdecl[@i] = 'color: ' .. @b .. ';'
		    let l:cssdecl[@x] = 'background-color: ' .. @f .. ';'
		elseif '' != @i && '' == @x
" Задан только цвет переднего плана. Присвоим ему значение цвета общего заднего
" плана, а цвет заднего плана для элемента — заданное значние
		    let l:cssdecl[@i] = 'color: ' .. s:bg_norm .. ';'
		    call add(l:cssdecl, 'background-color: ' .. @f .. ';')
		elseif '' == @i && '' != @x
" Здесь же наоборот, присвоено значение только для заднего плана
		    call add(l:cssdecl, 'color: ' .. @b .. ';')
		    let l:cssdecl[@x] = 'background-color: ' .. s:fg_norm .. ';'
		elseif '' == @i && '' == @x
" Есть реверс, но нет заданных значений. Используем общее значение
		    call add(l:cssdecl, 'color: ' .. s:bg_norm .. ';')
		    call add(l:cssdecl, 'background-color: ' .. s:fg_norm .. ';')
		endif
	    else
		return -1
	    endif
	endif

	if get(a:hiattr, 'rset') && !s:is_norm
" Сбросим всё к чертям, даже если и не задано
	    let l:idx = match(l:cssdecl, 'font-weight')
	    if 0 <= l:idx
		let l:cssdecl[l:idx] = 'font-weight: normal;'
	    else
		call add(l:cssdecl, 'font-weight: normal;')
	    endif
	    let l:idx = match(l:cssdecl, 'font-style')
	    if 0 <= l:idx
		let l:cssdecl[l:idx] = 'font-style: normal;'
	    else
		call add(l:cssdecl, 'font-style: normal;')
	    endif
	    let l:idx = match(l:cssdecl, 'text-decoration')
	    if 0 <= l:idx
		let l:cssdecl[l:idx] = 'text-decoration: none;'
	    else
		call add(l:cssdecl, 'text-decoration: none;')
	    endif
	    let l:idx = match(l:cssdecl, 'text-decoration-color')
	    if 0 <= l:idx
		let l:cssdecl[l:idx] =
		    \ '-moz-text-decoration-color: currentColor;'
		    \ .. ' -webkit-text-decoration-color: currentColor;'
		    \ .. ' text-decoration-color: currentColor;'
	    endif
	endif

	if get(a:hiattr, 'lum')
" что‐то делаем
	endif

	if get(a:hiattr, 'ncomb')
" что‐то делаем
	endif
	let l:cssdecl[0] = '{' .. l:cssdecl[0]
	let l:cssdecl[-1] = l:cssdecl[-1] .. '}'
	return l:cssdecl
    endif
    return -1
endfunction
