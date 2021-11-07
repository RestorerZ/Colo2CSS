






function HiAttr2CssDecl(hiattr)
    if !has_key(s:hi_attr, 'font') && s:is_norm
	let l:fnt = s:ParseFont(getfontname())
	if type(0) == type(l:fnt) && -1 == l:fnt
	    return -1
	endif
    else
	let l:fnt = s:hi_attr['font']
    endif
    if !empty(l:fnt)
	if has_key(l:fnt, 'fntname')
	    let s:css_decl = add(s:css_decl, 'font-family: "' .. l:fnt['fntname'] .. '", monospace;')
	endif
" Единицы измерения установлены в 'pt', т. е. пункты, для Win32 как указано в
" *gui-font*,
" для GTK (2|3) как указано в
" https://www.freedesktop.org/software/fontconfig/fontconfig-user.html
" для X11 как указано в *XLFD*, поле POINT. Надо только разделить на число 10
" Для MacOS надо будет смотреть ещё.
	if has_key(l:fnt, 'fnthght')
	    let s:css_decl = add(s:css_decl, 'font-size: ' .. (has('X11') ? l:fnt['fnthght']/10 : l:fnt['fntghght']) .. 'pt;')
	endif
	if has_key(l:fnt, 'fntwdt')
" НАДО: посмотреть как в win32 реализовано вычисление ширины символов и как это
" соотносится с этим правилом CSS
	    if has('X11')
" НАДО: составить какую‐то таблицу соотношения и соответствующую замену. Не все
" ключевые слова (описание свойства) из XLFD применимы к этому CSS правилу.
		let s:css_decl = add(s:css_decl, 'font-stretch: ' .. (tr(l:fnt['fntwdt'], ' ', '-')) .. ';')
	    endif
	endif
	if has_key(l:fnt, 'fntwght')
	    let s:css_decl = add(s:css_decl, 'font-weight: ' .. l:fnt['fntwght'] .. ';')
	endif
	if has_key(l:fnt, 'fntbold') && 1 == get(l:fnt, 'fntbold')
"   if get(l:fnt, 'fntbold')
	    let s:css_decl = add(s:css_decl, 'font-weight: bold;')
	endif
	if has_key(l:fnt, 'fntitlc') && 1 == get(l:fnt, 'fntitlc')
"   if get(l:fnt, 'fntitlc')
	    let s:css_decl = add(s:css_decl, 'font-style: italic;')
	endif
	if has_key(l:fnt, 'fntundr') && 1 == get(l:fnt, 'fntundr')
"   if get(l:fnt, 'fntundr')
	    let s:css_decl = add(s:css_decl, 'text-decoration: underline;')
	endif
	if has_key(l:fnt, 'fntsout') && 1 == get(l:fnt, 'fntsout')
"   if get(l:fnt, 'fntsout')
	    let l:idx = match(s:css_decl, 'text-decoration')
	    if 0 <= l:idx
		let s:css_decl[l:idx] = trim(s:css_decl[l:idx], ';', 2) .. ' line-throught;'
	    else
		let s:css_decl = add(s:css_decl, 'text-decoration: line-throught;')
	    endif
"	    let l:idx = ""
	endif
    endif
    if has_key(s:hi_attr, 'wght') && 1 == get(s:hi_attr, 'wght')
" if get(s:hi_attr, 'wght')
	let l:idx = match(s:css_decl, 'font-weight')
	if 0 <= l:idx
	    if 0 > match(s:css_decl[l:idx], 'bold')
		let s:css_decl[l:idx] = 'font-weight: bold;'
	    endif
	else
	    let s:css_decl = add(s:css_decl, 'font-weight: bold;')
	endif
    endif
    if has_key(s:hi_attr, 'itlc') && 1 == get(s:hi_attr, 'itlc')
" if get(s:hi_attr, 'itlc')
	let l:idx = match(s:css_decl, 'font-style:')
	if 0 <= l:idx
	    if 0 > match(s:css_decl[l:idx], 'italic')
		let s:css_decl[l:idx] = 'font-style: italic;'
	    endif
	else
	    let s:css_decl = add(s:css_decl, 'font-style: italic;')
	endif
    endif
    if has_key(s:hi_attr, 'undlne') && 1 == get(s:hi_attr, 'undlne')
" if get(s:hi_attr, 'undlne')
	let l:idx = match(s:css_decl, 'text-decoration')
	if 0 <= l:idx
	    if 0 > match(s:css_decl[l:idx], 'underline')
		let s:css_decl[l:idx] = trim(s:css_decl[l:idx], ';', 2) .. ' underline;'
	    endif
	else
	    let s:css_decl = add(s:css_decl, 'text-decoration: underline;')
	endif
    endif
    if has_key(s:hi_attr, 'skthro') && 1 == get(s:hi_attr, 'skthro')
" if get(s:hi_attr, 'skthro')
	let l:idx = match(s:css_decl, 'text-decoration')
	if 0 <= l:idx
	    if 0 > match(s:css_decl[l:idx], 'line-throught')
		let s:css_decl[l:idx] = trim(s:css_decl[l:idx], ';', 2) .. ' line-throught;'
	    endif
	else
	    let s:css_decl = add(s:css_decl, 'text-decoration: line-throught;')
	endif
    endif
    if has_key(s:hi_attr, 'undcrl') && 1 == get(s:hi_attr, 'undcrl')
" if get(s:hi_attr, 'undcrl')
	let tdecor = '-moz-text-decoration-line: underline;'
	let tdecor = tdecor .. ' -moz-text-decoration-style: wavy;'
	let tdecor = tdecor .. ' -webkit-text-decoration-line: underline;'
	let tdecor = tdecor .. ' -webkit-text-decoration-style: wavy;'
	let tdecor = tdecor .. ' text-decoration-line: underline;'
	let tdecor = tdecor .. ' text-decoration-style: wavy;'
    endif
    if has_key(s:hi_attr, 'rvrs') && 1 == get(s:hi_attr, 'rvrs')
" if get(s:hi_attr, 'rvrs')
" что‐то делаем
" проверка на NORMAL, если ИСТИНА, то ничего не делаем
" меняем цвета переднего и заднего плана местами
    endif
    if has_key(s:hi_attr, 'rset') && 1 == get(s:hi_attr, 'rset')
" if get(s:hi_attr, 'rset')
" что‐то делаем
" сбрасываем какие‐то свойства. Надо понять, какие свойства сбрасывать
    endif
    if has_key(s:hi_attr, 'lum') && 1 == get(s:hi_attr, 'lum')
" if get(s:hi_attr, 'lum')
" что‐то делаем
    endif
    if has_key(s:hi_attr, 'ncomb') && 1 == get(s:hi_attr, 'ncomb')
"if get(s:hi_attr, 'ncomb')
" что‐то делаем
    endif
    if has_key(s:hi_attr, 'color')
	let l:fgc = get(s:hi_attr, 'color')
	if 'NONE' ==? l:fgc
	    let fgcolo = 'color: inherit;'
	elseif 'bg' ==? l:fgc
" что‐то делаем
	elseif 'fg' ==? l:fgc
" что‐то делаем
	else
	    let fgcolo = 'color: ' .. l:fgc .. ';'
	endif
    endif
    if has_key(s:hi_attr, 'bg')
	let l:bgc = get(s:hi_attr, 'bg')
	if 'NONE' ==? l:bgc
	    let bgcolo = 'background-color: transparent;'
	elseif 'bg' ==? l:bgc
" что‐то делаем
	elseif 'fg' ==? l:bgc
" что‐то делаем
	else
	    let bgcolo = 'background-color: ' .. l:bgc .. ';'
	endif
    endif
    if has_key(s:hi_attr, 'decolo')
	let l:tdc = get(s:hi_attr, 'decolo')
	if 'NONE' ==? l:tdc
	    let tdecolo = 'text-decoration: none;'
	    let tdecolo = tdecolo .. ' -moz-text-decoration-line: none;'
	    let tdecolo = tdecolo .. ' -moz-text-decoration-color: currentColor;'
	    let tdecolo = tdecolo .. ' -webkit-text-decoration-line: none;'
	    let tdecolo = tdecolo .. ' -webkit-text-decoration-color: currentColor;'
	    let tdecolo = tdecolo .. ' text-decoration-line: none;'
	    let tdecolo = tdtcolo .. ' text-decoration-color: currentColor;'
	elseif 'bg' ==? l:tdc
" что‐то делаем
	elseif 'fg' ==? l:tdc
" что‐то делаем
	else
	    let tdecolo = '-moz-text-decoration-color: ' .. l:tdc .. ';'
	    let tdecolo = ' -webkit-text-decoration-color: ' .. l:tdc .. ';'
	    let tdecolo = ' text-decoration-color: ' .. l:tdc .. ';'
	endif
    endif
    return " что‐то надо вернуть
endfunction
