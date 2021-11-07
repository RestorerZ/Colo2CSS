
let s:rgbdos = 0


"	    let s:css_rule['selector'] = s:GetLnkGrp(l:grpname, @l)

"	    let s:css_rule = s:GetLnkGrp(l:grpname)

"	    let s:css_entry['selector'] = insert(s:css_entry['selector'], s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)

"	    let s:css_rule[0][0] = s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. ' ' .. s:css_rule[0][0]

"		let s:css_rule = add(s:css_rule, s:HiAttr2CssDecl(s:hi_attr))

"	    let g:css_entries = add(g:css_entries, s:css_rule)





function s:LFrgb2CRrgb()
" Как оказалось, findstr не ищет нормально окончание строк в файлах с
" unix‐форматом. Неожиданно, да? Либо я не придумал как ему это объяснить,
" чтобы он распознавал символ LF (10, 0xA) как конец строки. Приходится
" заниматься таким вот извратом. Это, конечно, полная херня и Содом, но, зато,
" узнал новые функции ;-). Есть, конечно, оптимальнее решение, я ещё подумаю.
    let rgbdos = 0
    let s:tmpdir = getenv('TEMP')
    if type(v:null) != type(s:tmpdir)
	let rgb = readfile(vimdir .. '\rgb.txt')
	if !empty(rgb)
	    call map(rgb, 'v:val .. ""')
	    if !writefile(rgb, tmpdir..'\rgb-dos.txt')
		let rgbdos = 1
	    endif
	endif
	unlet! rgb
    endif
    return rgbdos
endfunction







function s:ConvColor(colostr)
    if empty(a:colostr)
	echoerr "Что‐то пошло не так"
	return -1
    endif
    let vimdir = getenv('VIMRUNTIME')
    if empty(getftype(vimdir ..'/rgb.txt'))
	echoerr "Отсутствует файл rgb.txt в каталоге программы Vim. Дальнейшая работа невозможна"
	return -1
    endif
    if has ('win32')
	if 0 <= stridx(a:colostr, 'sys_')

PS D:\Users\Admin> Get-ItemProperty -path "Registry::HKCU\Control Panel\Colors" -Name MenuHilight | select-object -expandproperty menuhilight
51 153 255
PS D:\Users\Admin> Get-ItemProperty -path "Registry::HKCU\Control Panel\Colors"
-Name MenuHilight | select-object -property menuhilight

MenuHilight
-----------
51 153 255
	    let rgbcolo = system('reg query "HKCU\Control Panel\Colors" /v ' .. s:winsys_colo[toupper(a:colostr)][0])
	    if !empty(rgbcolo)
		let rgbcolo = matchstr(rgbcolo, '\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
	    endif
	    " что‐то делаем
	else
	    " делаем что‐то
	    if !s:rgbdos
		if call s:LFrgb2CRrgb()
		    let s:rgbdos = 1
		else
		    return -1
		endif
	    endif
	    let rgbcolo = system('findstr /I /R /C:"\<' ..a:colostr .. '\>" ' .. s:tmpdir .. '\rgb-dos.txt')
	    if !empty(rgbcolo)
		let rgbcolo = matchstr(rgbcolo, '\_^\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
	    endif

:echo system("powershell select-string -path " ..$VIMRUNTIME .. "\\rgb.txt -pattern " .. "'\\t" .. pat .. "$'") 
:echo system("powershell select-string -path " ..$VIMRUNTIME .. "\\rgb.txt -pattern " .. "'\\t" .. pat .. "$'" .. "^|" .. "select-object -expandproperty line") 

	endif
    elseif has ('unix')
	" делаем что‐то
	let rgbcolo = system('grep.exe -i -w "[[:space:]]\<violet$"' ..vimdir.. '\rgb.txt')

	    if !empty(rgbcolo)
" Буду в виртулках Windows поднимать, надо и что‐нибудь и UNIX-подобное поднять.  
		let rgbcolo = matchstr(rgbcolo, '\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
		echo 'rgbcolo after match ' rgbcolo
		let hexcolo = ""
		while !empty(rgbcolo)
		    let @d = ""
		    let @d = matchstr(rgbcolo, '\_^\d\{1,3}')
		    let rgbcolo = substitute(rgbcolo, @d .. '\s*', '', '')
"			let rgbcolo = execute(rgbcolo)
"		    let rgbcolo = execute 'normal "ddw' .. rgbcolo
		    let hexcolo = hexcolo .. s:Dec2Hex(@d)
		endwhile
		return hexcolo
	    endif

    endif
    endif
    return -1
endfunction







function ParseHiArgs(lnum)
let s:hi_attr = {}
    for hiarg in s:hi_args
	let @s = ""
	if 'gui' == hiarg
	    let l:pos = matchend(getline(a:lnum), hiarg .. '=')
	    if 0 <= l:pos
" Если присутствует в строке, копируем значение до пробельного символа
		let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, 'W')
		if empty(@s)
		    echoerr "Что‐то пошло не так"
		else
" Если в строке будут символы запятой, заменим их на пробел
		    let @s = tr(@s, ',', ' ')
		    for attr in s:spec_attr
			if 0 <= (stridx(@s, attr[0])) 
" При наличии наименования аттрибута из массива, присваиваем значение
" соответствующему наименованию ключа словаря
			    let s:hi_attr[attr[1]] = 1
" и удаляем из строки наименование аттрибута
" НАДО: Заменить функцию trim на что‐то другое. Она вырезает не слово целиком,
" сопадающие символы в слове
"			    let @s = trim(@s, attr[0] .. " ", 1)
			    let @s = substitute(@s, attr[0]..'\s\=', '', 'g')
			    if empty(@s)
" Завершаем цикл проверки наименований аттрибутов, т. к. строка уже пустая
				break
			    endif
			endif
		    endfor
		endif
	    endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
	    continue
	elseif 'guifg' == hiarg
	    let pos = matchend(getline(a:lnum), hiarg .. '=')
	    if 0 <= pos
" НАДО: Сделать проверку и, соответственно, копирование наименования цвета при
" указании его в одинарных кавычках
		let @s = s:GetEntry(0, a:lnum, pos+1, 0, 'W')
		if empty(@s)
		    echoerr "Что‐то пошло не так"
		else
		    let @s = s:GetColor(@s)
		    if !empty(@s)
			if 'NONE' == getreg('s')
			    let s:hi_attr['color'] = 'inherit'
			else
			    let s:hi_attr['color'] = getreg('s')
			endif
		    endif
		endif
	    endif
	    continue
	elseif 'guibg' == hiarg
	    let pos = matchend(getline(a:lnum), hiarg .. '=')
	    if 0 <= pos
" НАДО: Сделать проверку и, соответственно, копирование наименования цвета при
" указании его в одинарных кавычках
		let @s = s:GetEntry(0, a:lnum, pos+1, 0, 'W')
		if empty(@s)
		    echoerr "Что‐то пошло не так"
		else
		    let @s = s:GetColor(@s)
		    if !empty(@s)
			if 'NONE' == getreg('s')
			    let s:hi_attr['bg'] = 'transparent'
			else
			    let s:hi_attr['bg'] = getreg('s')
			endif
		    endif
		endif
	    endif
	    continue
	elseif 'guisp' == hiarg
	    let pos = matchend(getline(a:lnum), hiarg .. '=')
	    if 0 <= pos
" НАДО: Сделать проверку и, соответственно, копирование наименования цвета при
" указании его в одинарных кавычках
		let @s = s:GetEntry(0, a:lnum, pos+1, 0, 'W')
		if empty(@s)
		    echoerr "Что‐то пошло не так"
		else
		    let @s = s:GetColor(@s)
		    if !empty(@s)
			if 'NONE' == getreg('s')
			    let s:hi_attr['decolo'] = 'currentColor'
			else
			    let s:hi_attr['decolo'] = getreg('s')
			endif
		    endif
		endif
	    endif
	    continue
	elseif 'font' == hiarg
	    let pos = matchend(getline(a:lnum), hiarg .. '=')
	    if 0 <= pos
		let @s = s:GetEntry(0, a:lnum, pos+1, 0, '$')
		if empty(@s)
		    echoerr "Что‐то пошло не так"
		else
" НАДО: Сделать проверку и, соответственно, копирование наименования шрифта при
" указании его с пробелами и обратной наклонной чертой
		" let fnt = s:ParseFont(@s)
		" echo 'fnt ' fnt
		" if 0 > fnt
		"    echoerr "Этот подключаемый модуль работает только в графическом интерфейсе"
		" endif
		" if empty(fnt)
		"    echoerr "Что‐то пошло не так при разборе значания строки шрифта"
		" else
		    let s:hi_attr['font'] = s:ParseFont(@s)
		"    let s:hi_attr['font'] = fnt
		" endif
		endif
	    endif
	endif
    endfor

echo s:hi_attr








endfunction








function ParseHiArgs(lnum)
let s:hi_attr = {}
    for l:hiarg in s:hi_args
	let @s = ""
	if 'gui' == l:hiarg
	    let l:pos = matchend(getline(a:lnum), l:hiarg .. '=')
	    if 0 <= l:pos
" Если присутствует в строке, копируем значение до пробельного символа
		let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, 'W')
		if !empty(@s)
" Если в строке будут символы запятой, заменим их на пробел
		    let @s = tr(@s, ',', ' ')
		    for attr in s:spec_attr
			if 0 <= (stridx(@s, attr[0])) 
" При наличии наименования аттрибута из массива, присваиваем значение
" соответствующему наименованию ключа словаря
			    let s:hi_attr[attr[1]] = 1
" и удаляем из строки наименование аттрибута
			    let @s = substitute(@s, '\c'..attr[0]..'\s\=', '', '')
			    if empty(@s)
" Завершаем цикл проверки наименований аттрибутов, т. к. строка уже пустая
				break
			    endif
			endif
		    endfor
		endif
	    endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
    continue
	elseif 'guifg' == l:hiarg
	    let l:pos = matchend(getline(a:lnum), l:hiarg .. '=')
	    if 0 <= l:pos
		if "'" == s:GetEntry(0, a:lnum, l:pos+1, 'l')
" Если после знака равенства символ одинарной кавычки, то копируем всё что
" внутри этих кавычек
		    let @s = s:GetEntry(0, a:lnum, l:pos+2, "i'")
		else
" Иначе целое СЛОВО, включая пробельный символ после него
		    let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, 'W')
		endif
		if !empty(@s)
		    let @s = s:GetColor(@s)
		    if !empty(@s)
			let s:hi_attr['color'] = getreg('s')
		    endif
		endif
	    endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
    continue
	elseif 'guibg' == l:hiarg
	    let l:pos = matchend(getline(a:lnum), l:hiarg .. '=')
	    if 0 <= l:pos
		if "'" == s:GetEntry(0, a:lnum, l:pos+1, 'l')
" Если после знака равенства символ одинарной кавычки, то копируем всё что
" внутри этих кавычек
		    let @s = s:GetEntry(0, a:lnum, l:pos+2, "i'")
		else
" Иначе целое СЛОВО, включая пробельный символ после него
		    let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, 'W')
		endif
		if !empty(@s)
		    let @s = s:GetColor(@s)
		    if !empty(@s)
			let s:hi_attr['bg'] = getreg('s')
		    endif
		endif
	    endif
    continue
	elseif 'guisp' == l:hiarg
	    let l:pos = matchend(getline(a:lnum), l:hiarg .. '=')
	    if 0 <= l:pos
		if "'" == s:GetEntry(0, a:lnum, l:pos+1, 'l')
" Если после знака равенства символ одинарной кавычки, то копируем всё что
" внутри этих кавычек
		    let @s = s:GetEntry(0, a:lnum, l:pos+2, "i'")
		else
" Иначе целое СЛОВО, включая пробельный символ после него
		    let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, 'W')
		endif
		if !empty(@s)
		    let @s = s:GetColor(@s)
		    if !empty(@s)
			let s:hi_attr['decolo'] = getreg('s')
		    endif
		endif
	    endif
    continue
	elseif 'font' == l:hiarg
	    let l:pos = matchend(getline(a:lnum), l:hiarg .. '=')
	    if 0 <= pos
		if "'" == s:GetEntry(0, a:lnum, l:pos+1, 'l')
" Если после знака равенства символ одинарной кавычки, то копируем всё что
" внутри этих кавычек
		    let @s = s:GetEntry(0, a:lnum, l:pos+2, "i'")
		else
" Иначе копируем до конца строки, т. к. я наедюсь, что аргумент font будет
" всегда последним в строке свойств группы
		    let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, '$')
		endif
		if !empty(@s)
		    let l:fnt = s:ParseFont(@s)
		    if type(0) != type(l:fnt) && !empty(l:fnt)
			let s:hi_attr['font'] = l:fnt
		    endif
		endif
	    endif
	endif
    endfor

echo s:hi_attr

return s:hi_attr
endfunction







let s:fnt_sze = ['h', 'w', 'W']

let s:hi_fnt = {}

function ParseFont(fntval)
    if !empty(a:fntval)
	if 'NONE' == a:fntval
	    let l:fnt = getfontname()
	else
	    let l:fnt = a:fntval
	if has ('gui_win32')
	    let l:cln = stridx(a:fntval, ':')
" НАДО: Реализовать очистку наименования шрифта от обратной наклонной черты
	    if 0 < l:cln
		let s:hi_fnt['fntname'] = tr(a:fntval[0:l:cln-1], '_', ' ')
	    elseif 0 > l:cln
		let s:hi_fnt['fntname'] = tr(a:fntval[0:l:cln], '_', ' ')
	    endif
	    for fntsze in s:fnt_sze
		let l:size = matchlist(a:fntval, '\C\(:'..fntsze..'\)\(\d\{1,}\.\{,1}\d\{}\)')
		if !empty(l:size)
		    if 'h' == fntsze
			let s:hi_fnt['fnthght'] = l:size[2]
			continue
		    elseif 'w' == fntsze
			let s:hi_fnt['fntwdth'] = l:size[2]
			continue
		    elseif 'W' == fntsze
			let s:hi_fnt['fntwght'] = l:size[2]
		    endif
		endif
	    endfor
" НАДО: Заменить match() на stridx() или что‐то такое не ресурсоёмкое	
	    if 0 < match(a:fntval, ':b')
		let s:hi_fnt['fntbold'] = 1
	    endif
	    if 0 < match(a:fntval, ':i')
		let s:hi_fnt['fntitlc'] = 1
	    endif
	    if 0 < match(a:fntval, ':u')
		let s:hi_fnt['fntundr'] = 1
	    endif
	    if 0 < match(a:fntval, ':s')
		let s:hi_fnt['fntsout'] = 1
	    endif
    echo get(s:hi_fnt, 'fntname')
    echo get(s:hi_fnt, 'fntbold')
    echo get(s:hi_fnt, 'fntitlc')
    echo get(s:hi_fnt, 'fntundr')
    echo get(s:hi_fnt, 'fntsout')
    echo get(s:hi_fnt, 'fnthght')
    echo get(s:hi_fnt, 'fntwdth')
    echo get(s:hi_fnt, 'fntwght')
	    return s:hi_fnt
    unlet s:hi_fnt
	elseif has ('gui_gtk2') || has ('gui_gtk3')
	    " doing something
	    " return s:hi_fnt
	elseif has ('X11')
	    " doing something
	    " return s:hi_fnt
	elseif has ('gui_mac')
	    " doing something
	    " return s:hi_fnt
	endif
    endif
    return -1
endfunction








function HiAttr2CssDecl(hiattr)
    






if has_key(s:hi_attr, 'font')
    if has_key(s:hi_attr['font'], 'fntname')
	let l:fnt = 'font-family: "' .. s:hi_attr['font']['fntname'] .. '", monospace;'
    endif
    if has_key(s:hi_attr['font'], 'fnthght')
	let fnt2 = 
	
	
	
	
	
	
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
	let l:fnt = 'font-family: "' .. l:fnt['fntname'] .. '", monospace;'
    endif
" Единицы измерения установлены в 'pt', т. е. пункты, для Win32 как указано в
" *gui-font* и для GTK (2|3) как указано в https://www.freedesktop.org/software/fontconfig/fontconfig-user.html
" Для X11 и MacOS надо будет смотреть ещё.
    if has_key(l:fnt, 'fnthght')
" Так плохо. Изменяется значение переменной в функции (побочный эффект).
" Выполнить это выражание непосредственно при присвоении что‐то не получается.
"
	    let l:fnt['fnthght'] = has('X11') ? l:fnt['fnthght']/10 : l:fnt['fntghght']

	let fnthght = 'font-size: ' .. l:fnt['fnthght'] .. 'pt;'
    endif
    if has_key(l:fnt, 'fntwdt')
" что‐то делаем
" НАДО: определится со свойством CSS, для которго применять значение ширины шрифта
    endif
    if has_key(l:fnt, 'fntwght')
	let fntwght = 'font-weight: ' .. l:fnt['fntwght'] .. ';'
    endif
    if has_key(l:fnt, 'fntbold') && 1 == get(l:fnt, 'fntbold')
"   if get(l:fnt, 'fntbold')
	let fntwght = 'font-weight: bold;'
    endif
    if has_key(l:fnt, 'fntitlc') && 1 == get(l:fnt, 'fntitlc')
"   if get(l:fnt, 'fntitlc')
	let fntstl = 'font-style: italic;'
    endif
    if has_key(l:fnt, 'fntundr') && 1 == get(l:fnt, 'fntundr')
"   if get(l:fnt, 'fntundr')
	let tdecor = 'text-decoration: underline;'
    endif
    if has_key(l:fnt, 'fntsout') && 1 == get(l:fnt, 'fntsout')
"   if get(l:fnt, 'fntsout')
	let tdecor = 'text-decoration: line-throught;'
    endif
endif
if has_key(s:hi_attr, 'wght') && 1 == get(s:hi_attr, 'wght')
" if get(s:hi_attr, 'wght')
    let fntwght = 'font-weight: bold;'
endif
if has_key(s:hi_attr, 'itlc') && 1 == get(s:hi_attr, 'itlc')
" if get(s:hi_attr, 'itlc')
    let fntstl = 'font-style: italic;'
endif
if has_key(s:hi_attr, 'undlne') && 1 == get(s:hi_attr, 'undlne')
" if get(s:hi_attr, 'undlne')
    let tdecor = 'text-decoration: underline;'
endif
if has_key(s:hi_attr, 'skthro') && 1 == get(s:hi_attr, 'skthro')
" if get(s:hi_attr, 'skthro')
    let tdecor = 'text-decoration: line-throught;'
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







" *win32-colors*
" https://russianblogs.com/article/8427240475/
" http://rusproject.narod.ru/winapi/g/getsyscolor.html
" https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
let s:winsys_colo = {'SYS_3DDKSHADOW':['ButtonDkShadow', 'COLOR_3DDKSHADOW', 21],
		\ 'SYS_3DHILIGHT':['ButtonHighlight', 'COLOR_3DHILIGHT', 20],
		\ 'SYS_3DHIGHLIGHT':['ButtonHighlight', 'COLOR_3DHIGHLIGHT', 20],
		\ 'SYS_BTNHILIGHT':['ButtonHighlight', 'COLOR_BTNHILIGHT', 20],
		\ 'SYS_BTNHIGHLIGHT':['ButtonHighlight', 'COLOR_BTNHIGHLIGHT', 20],
		\ 'SYS_3DLIGHT':['ButtonLight', 'COLOR_3DLIGHT', 22],
		\ 'SYS_3DSHADOW':['ButtonShadow', 'COLOR_3DSHADOW', 16],
		\ 'SYS_DESKTOP':['Background', 'COLOR_DESKTOP', 1],
		\ 'SYS_INFOBK':['InfoWindow', 'COLOR_INFOBK', 24],
		\ 'SYS_INFOTEXT':['InfoText', 'COLOR_INFOTEXT', 23],
		\ 'SYS_3DFACE':['ButtonFace', 'COLOR_3DFACE', 15],
		\ 'SYS_BTNFACE':['ButtonFace', 'COLOR_BTNFACE', 15],
		\ 'SYS_BTNSHADOW':['ButtonShadow', 'COLOR_BTNSHADOW', 16],
		\ 'SYS_ACTIVEBORDER':['ActiveBorder', 'COLOR_ACTIVEBORDER', 10],
		\ 'SYS_ACTIVECAPTION':['ActiveTitle', 'COLOR_ACTIVECAPTION', 2],
		\ 'SYS_APPWORKSPACE':['AppWorkspace', 'COLOR_APPWORKSPACE', 12],
		\ 'SYS_BACKGROUND':['Background', 'COLOR_BACKGROUND', 1],
		\ 'SYS_BTNTEXT':['ButtonText', 'COLOR_BTNTEXT', 18],
		\ 'SYS_CAPTIONTEXT':['TitleText', 'COLOR_CAPTIONTEXT', 9],
		\ 'SYS_GRAYTEXT':['GrayText', 'COLOR_GRAYTEXT', 17],
		\ 'SYS_HIGHLIGHT':['Hilight', 'COLOR_HIGHLIGHT', 13],
		\ 'SYS_HIGHLIGHTTEXT':['HilightText', 'COLOR_HIGHLIGHTTEXT', 14],
		\ 'SYS_INACTIVEBORDER':['InactiveBorder', 'COLOR_INACTIVEBORDER', 11],
		\ 'SYS_INACTIVECAPTION':['InactiveTitle', 'COLOR_INACTIVECAPTION', 3],
		\ 'SYS_INACTIVECAPTIONTEXT':['InactiveTitleText', 'COLOR_INACTIVECAPTIONTEXT', 19],
		\ 'SYS_MENU':['Menu', 'COLOR_MENU', 4],
		\ 'SYS_MENUTEXT':['MenuText', 'COLOR_MENUTEXT', 7],
		\ 'SYS_SCROLLBAR':['Scrollbar', 'COLOR_SCROLLBAR', 0],
		\ 'SYS_WINDOW':['Window', 'COLOR_WINDOW', 5],
		\ 'SYS_WINDOWFRAME':['WindowFrame', 'COLOR_WINDOWFRAME', 6],
		\ 'SYS_WINDOWTEXT':['WindowText', 'COLOR_WINDOWTEXT', 8]
		\ }

function s:ColoStr2ColoNum(colostr)
    if !empty(a:colostr)
	if filereadable($VIMRUNTIME .. '/rgb.txt')
	    let l:rgbcolo = ""
	    if has('win32')
		if 0 <= stridx(toupper(a:colostr), 'SYS_', 0)
"		    let l:rgbcolo = system('reg query "HKUC\Control Panel\Colors" /v ' .. s:winsys_colo[toupper(a:colostr)][0])
" Попробуем вот такую конструкцию. Гулять, так гулять... Будь внимателен с
" кавычками, наклонной чертой и проч. спецсимволами, экранируй их правильно.
		    let l:rgbcolo = system("powershell Get-ItemProperty -Path 'Registry::HKCU\\Control Panel\\Colors' -Name " .. s:winsys_colo[toupper(a:colostr)][0] .. " ^| Select-Object -ExpandProperty " .. s:winsys_colo[toupper(a:colostr)][0])
		else
"		    let l:rgbcolo = system('findstr /I /R /E /C:"\<' .. a:colostr .. '\>" ' .. $VIMRUNTIME ..'\rgb-dos.txt')
" Не очень просто получается с findstr. Пробуем ещё одну штуковину. Весь это
" powershell надо, конечно, тестировать и тестировать. ХЗ, как будет на других
" машинах. Надо поднимать ВМ...
		    let l:rgbcolo = system("powershell Select-String -Path " .. $VIMRUNTIME .. "\\rgb.txt -Pattern " .. "'\\t" .. a:colostr .. "$'" .. " ^| " .. "Select-Object -ExpandProperty Line")
		endif
	    elseif has('unix')
" Буду в виртуалках Windows поднимать, надо что‐нибудь и UNIX-подобное поднять.  
		let l:rgbcolo = system('grep -i -h -w -e "[[:space:]]' .. a:colostr .. '$" ' ..$VIMRUNTIME .. '/rgb.txt')
	    endif
	    if !empty(l:rgbcolo)
		let l:hexcolo = ""
		let l:rgbcolo = matchstr(l:rgbcolo, '\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
		while !empty(l:rgbcolo)
		    let @d = ""
		    let @d = matchstr(l:rgbcolo, '\_^\d\{1,3}')
		    let l:rgbcolo = substitute(l:rgbcolo, @d .. '\s*', '', '')
"		    let l:hexcolo = l:hexcolo .. s:Dec2Hex(@d)
		    let @d = s:Dec2Hex(@d)
		    if 0xff < str2nr(@d, 16)
			return -1
		    endif
		    let l:hexcolo = l:hexcolo .. @d
		endwhile
		return l:hexcolo
	    endif
	endif
    endif
    return -1
endfunction







function s:GetColor(colo)
    if !empty(a:colo)
	if '#' == strcharpart(a:colo, 0, 1)
	    return trim(a:colo)
	elseif 0 <= stridx(tolower(a:colo), 'bg') || 0 <= stridx(tolower(a:colo), 'background')
	    return 'bg'
	elseif 0 <= stridx(tolower(a:colo), 'fg') || 0 <= stridx(tolower(a:colo), 'foreground')
	    return 'fg'
	elseif 0 <= stridx(toupper(a:colo), 'NONE')
	    return 'NONE'
	elseif 0 <= match(a:colo, '\w\+')
	    let @l = ""
	    let @l = s:ColoStr2ColoNum(a:colo)
	    if !empty(@l) && 0 <= @l 
"		let @l = '#' .. @l
		return '#' .. @l
	    endif
	endif
    endif
    return -1
endfunction









function ParseHiArgs(lnum)
let s:hi_attr = {}
    let l:str = getline(a:lnum)
    for l:hiarg in s:hi_args
	let @s = ""
	if 'gui' == l:hiarg
	    let l:pos = matchend(l:str, l:hiarg .. '=')
	    if 0 <= l:pos
" Если присутствует в строке, копируем значение до пробельного символа
		let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, 't ')
		if !empty(@s)
" Если в строке будут символы запятой, заменим их на пробел
		    let @s = tr(@s, ',', ' ')
		    for attr in s:spec_attr
			if 0 <= (stridx(@s, attr[0])) 
" При наличии наименования аттрибута из массива, присваиваем значение
" соответствующему наименованию ключа словаря
			    let s:hi_attr[attr[1]] = 1
" и удаляем из строки наименование аттрибута
			    let @s = substitute(@s, '\c'..attr[0]..'\s\=', '', '')
			    if empty(@s)
" Завершаем цикл проверки наименований аттрибутов, т. к. строка уже пустая
				break
			    endif
			endif
		    endfor
		endif
	    endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
    continue
	elseif 'guifg' == l:hiarg || 'guibg' == l:hiarg || 'guisp' == l:hiarg
	    let l:pos = matchend(l:str, l:hiarg .. '=')
	    if 0 <= l:pos
		if "'" == s:GetEntry(0, a:lnum, l:pos+1, 0, 'l')
" Если после знака равенства символ одинарной кавычки, то копируем всё что
" внутри этих кавычек
		    let @s = s:GetEntry(0, a:lnum, l:pos+2, 0, "i'")
		else
" Иначе целое СЛОВО, включая пробельный символ после него с последующим удалением
		    let @s = trim(s:GetEntry(0, a:lnum, l:pos+1, 0, 'W'), ' ', 2)
		endif
		if !empty(@s)
		    let @s = s:GetColor(@s)
		    if !empty(@s) && 0 <= @s
			if 'guifg' == l:hiarg
			    let s:hi_attr['color'] = getreg('s')
			elseif 'guibg' == l:hiarg
			    let s:hi_attr['bg'] = getreg('s')
			elseif 'guisp' == l:hiarg
			    let s:hi_attr['decolo'] = getreg('s')
			endif
		    else
			return -1
		    endif
		endif
	    endif
" Запускаем новый шаг цикла поиска аргумента группы подсветки
    continue
	elseif 'font' == l:hiarg
	    let l:pos = matchend(l:str, l:hiarg .. '=')
	    if 0 <= l:pos
		if "'" == s:GetEntry(0, a:lnum, l:pos+1, 0, 'l')
" Если после знака равенства символ одинарной кавычки, то копируем всё что
" внутри этих кавычек
		    let @s = s:GetEntry(0, a:lnum, l:pos+2, 0, "i'")
		else
" Иначе копируем до конца строки, т. к. я надеюсь, что аргумент font будет
" всегда последним в строке свойств группы
		    let @s = s:GetEntry(0, a:lnum, l:pos+1, 0, '$')
		endif
		if !empty(@s)
		    let l:fnt = s:ParseFont(@s)
		    if type(0) != type(l:fnt) && !empty(l:fnt)
			let s:hi_attr['font'] = l:fnt
		    endif
		endif
	    endif
	endif
    endfor

echo s:hi_attr

return s:hi_attr
endfunction

"unlet s:hi_attr



function s:HiAttr2CssDecl(hiattr)
"    let hiattr = eval(a:hiattr)
    let l:css_decl = []
    let l:fnt = ''
    if !has_key(a:hiattr, 'font') && s:is_norm
"	echo 'is_norm' s:is_norm
	let l:fnt = s:ParseFont(getfontname())
	if type(0) == type(l:fnt) && -1 == l:fnt
	    return -1
	endif
    elseif has_key(a:hiattr, 'font')
	let l:fnt = a:hiattr['font']
	let l:fnt = get(a:hiattr, 'font')
    endif

    if !empty(l:fnt)
" Формируем правила для шрифта
	if has_key(l:fnt, 'fntname')
	    let l:css_decl = add(l:css_decl, 'font-family: "' .. l:fnt['fntname'] .. '", monospace;')
	endif
	if has_key(l:fnt, 'fnthght')
	    let l:css_decl = add(l:css_decl, 'font-size: ' .. (has('X11') ? l:fnt['fnthght']/10 : l:fnt['fnthght']) .. 'pt;')
	endif
	if has_key(l:fnt, 'fntwdt')
	    if has('X11')
		let l:css_decl = add(l:css_decl, 'font-stretch: ' .. (tr(l:fnt['fntwdt'], ' ', '-')) .. ';')
	    endif
	endif
	if has_key(l:fnt, 'fntwght')
	    let l:css_decl = add(l:css_decl, 'font-weight: ' .. l:fnt['fntwght'] .. ';')
	endif
	if get(l:fnt, 'fntbold')
	    let l:idx = match(l:css_decl, 'font-weight')
	    if 0 <= l:idx
		let l:css_decl[l:idx] = 'font-weight: bold;'
	    else
		let l:css_decl = add(l:css_decl, 'font-weight: bold;') 
	    endif
	endif
	if get(l:fnt, 'fntitlc')
	    let l:css_decl = add(l:css_decl, 'font-style: italic;')
	endif
    endif

    if get(a:hiattr, 'wght')
	let l:idx = match(l:css_decl, 'font-weight')
	if 0 <= l:idx
	    if 0 > match(l:css_decl[l:idx], 'bold')
		let l:css_decl[l:idx] = 'font-weight: bold;'
	    endif
	else
	    let l:css_decl = add(l:css_decl, 'font-weight: bold;')
	endif
    endif

    if get(a:hiattr, 'itlc')
	let l:idx = match(l:css_decl, 'font-style:')
	if 0 <= l:idx
	    if 0 > match(l:css_decl[l:idx], 'italic')
		let l:css_decl[l:idx] = 'font-style: italic;'
	    endif
	else
	    let l:css_decl = add(l:css_decl, 'font-style: italic;')
	endif
    endif

" Формируем правила для цвета заднего и переднего плана
    if has_key(a:hiattr, 'bg')
	let l:bgc = get(a:hiattr, 'bg')
	if 'NONE' ==? l:bgc && !s:is_norm
	    let l:idx = match(l:css_decl, 'backround-color')
	    if 0 <= l:idx
		let l:css_decl[l:idc] = 'background-color: transparent;'
	    else
		let l:css_decl = add(l:css_decl, 'background-color: transparent;')
	    endif
	elseif 'bg' ==? l:bgc && !s:is_norm
	    if s:bg_norm
		let l:idx = match(l:css_decl, 'background-color')
		if 0 <=l:idx
		    let l:css_decl[l:idx] = 'background-color: ' .. s:bg_norm
		else
		    let l:css_decl = add(l:css_decl, 'background-color: ' .. s:bg_norm)
		endif
	    else
		return -1
	    endif
	elseif 'fg' ==? l:bgc && !s:is_norm
	    if s:fg_norm
		let l:idx = match(l:css_decl, 'background-color')
		if 0 <=l:idx
		    let l:css_decl[l:idx] = 'background-color: ' .. s:fg_norm
		else
		    let l:css_decl = add(l:css_decl, 'background-color: ' .. s:fg_norm)
		endif
	    else
		return -1
	    endif
	else
	    let l:css_decl = add(l:css_decl, 'background-color: ' .. l:bgc .. ';')
	    let s:bg_norm = s:is_norm ? l:bgc : s:bg_norm
	endif
    endif

    if has_key(a:hiattr, 'color')
	let l:fgc = get(a:hiattr, 'color')
	if 'NONE' ==? l:fgc && !s:is_norm
	    let l:idx = match(l:css_decl, '\<color')
	    if 0 <= l:idx
		let l:css_decl[l:idx] = 'color: inherit;'
	    else
		let l:css_decl = add(l:css_decl, 'color: inherit;')
	    endif
	elseif 'bg' ==? l:fgc && !s:is_norm
	    if s:bg_norm
		let l:idx = match(l:css_decl, '\<color')
		if 0 <= l:idx
		    let l:css_decl[l:idx] = 'color: ' .. s:bg_norm .. ';'
		else
		    let l:css_decl = add(l:css_decl, 'color: ' .. s:bg_norm .. ';')
		endif
	    else
		return -1
	    endif
	elseif 'fg' ==? l:fgc && !s:is_norm
	    if s:fg_norm
		let l:idx = match(l:css_decl, '\<color')
		if 0 <= l:idx
		    let l:css_decl[l:idx] = 'color: ' .. s:fg_norm .. ';'
		else
		    let l:css_decl = add(l:css_decl, 'color: ' .. s:fg_norm .. ';')
		endif
	    else
		return -1
	    endif
	else
	    let l:css_decl = add(l:css_decl, 'color: ' .. l:fgc .. ';')
	    let s:fg_norm = s:is_norm ? l:fgc : s:fg_norm
	endif
    endif

    if !empty(l:fnt)
	if get(l:fnt, 'fntundr')
	   let l:idx = match(l:css_decl, 'text-decoration')
	   if 0 <= l:idx
		let l:css_decl[l:idx] = trim(l:css_decl[l:idx], ';', 2) .. ' underline;'
	   else
		let l:css_decl = add(l:css_decl, 'text-decoration: underline;')
	    endif
	endif
	if get(l:fnt, 'fntsout')
	    let l:idx = match(l:css_decl, 'text-decoration')
	    if 0 <= l:idx
		let l:css_decl[l:idx] = trim(l:css_decl[l:idx], ';', 2) .. ' line-throught;'
	    else
		let l:css_decl = add(l:css_decl, 'text-decoration: line-throught;')
	    endif
	endif
    endif

    if get(a:hiattr, 'undlne') && !s:is_norm
	let l:idx = match(l:css_decl, 'text-decoration')
	if 0 <= l:idx
	    if 0 > match(l:css_decl[l:idx], 'underline')
		let l:css_decl[l:idx] = trim(l:css_decl[l:idx], ';', 2) .. ' underline;'
	    endif
	else
	    let l:css_decl = add(l:css_decl, 'text-decoration: underline;')
	endif
    endif

    if get(a:hiattr, 'skthro') && !s:is_norm
	let l:idx = match(l:css_decl, 'text-decoration')
	if 0 <= l:idx
	    if 0 > match(l:css_decl[l:idx], 'line-throught')
		let l:css_decl[l:idx] = trim(l:css_decl[l:idx], ';', 2) .. ' line-throught;'
	    endif
	else
	    let l:css_decl = add(l:css_decl, 'text-decoration: line-throught;')
	endif
    endif

    if get(a:hiattr, 'undcrl') && !s:is_norm
	let l:css_decl = add(l:css_decl,
	\ '-moz-text-decoration-line: underline; -moz-text-decoration-style: wavy;'
	\ .. ' -webkit-text-decoration-line: underline; -webkit-text-decoration-style: wavy;'
	\ .. ' text-decoration-line: underline; text-decoration-style: wavy;')
    endif

    if has_key(a:hiattr, 'decolo') && !s:is_norm
	let l:tdc = get(a:hiattr, 'decolo')
	if 'NONE' ==? l:tdc
	    let l:css_decl = add(l:css_decl,
	    \ '-moz-text-decoration-color: currentColor;'
	    \ .. ' -webkit-text-decoration-color: currentColor;'
	    \ .. ' text-decoration-color: currentColor;')
	elseif 'bg' ==? l:tdc
	    if s:bg_norm
		let l:css_decl = add(l:css_decl,
		\ '-moz-text-decoration-color: ' .. s:bg_norm .. ';'
		\ .. ' -webkit-text-decoration-color: ' .. s:bg_norm .. ';'
		\ .. ' text-decoration-color: ' .. s:bg_norm .. ';')
	    else
		return -1
	    endif
	elseif 'fg' ==? l:tdc
	    if s:fg_norm
		let l:css_decl = add(l:css_decl,
		\ '-moz-text-decoration-color: ' .. s:fg_norm .. ';'
		\ .. ' -webkit-text-decoration-color: ' .. s:fg_norm .. ';'
		\ .. ' text-decoration-color: ' .. s:fg_norm .. ';')
	    else
		return -1
	    endif
	else
	    let l:css_decl = add(l:css_decl,
	    \ '-moz-text-decoration-color: ' .. l:tdc .. ';'
	    \ .. ' -webkit-text-decoration-color: ' .. l:tdc .. ';'
	    \ .. ' text-decoration-color: ' .. l:tdc .. ';')
	endif
    endif

    if get(a:hiattr, 'rvrs') && !s:is_norm
	if s:fg_norm && s:bg_norm
	    let @i = ''
	    let @f = ''
	    let @x = ''
	    let @b = ''
	    let l:idx = match(l:css_decl, '\<color')
	    if 0 <= l:idx
		let @i = l:idx
		let @f = l:css_decl[l:idx]
	    endif
	    let l:idx = match(l:css_decl, 'background-color')
	    if 0 <= l:idx
		let @x = l:idx
		let @b = l:css_decl[l:idx]
	    endif
	    if @f && @b
		let l:css_decl[@i] = 'color: ' .. @b .. ';'
		let l:css_decl[@x] = 'background-color: ' .. @f .. ';'
	    elseif @f && !@b
		let l:css_decl[@i] = 'color: ' .. s:bg_norm .. ';'
		let l:css_decl = add(l:css_decl, 'background-color: ' .. @f .. ';')
	    elseif !@f && @b
		let l:css_decl = add(l:css_decl, 'color: ' .. @b .. ';')
		let l:css_decl[@x] = 'background-color: ' .. s:fg_norm .. ';'
	    elseif !@f && !@b
		let l:css_decl = add(l:css_decl, 'color: ' .. s:bg_norm .. ';')
		let l:css_decl = add(l:css_decl, 'background-color: ' .. s:fg_norm .. ';')
	    endif
	else
	    return -1
	endif
    endif

    if get(a:hiattr, 'rset') && !s:is_norm
	let l:idx = match(l:css_decl, 'font-weight')
	if 0 <= l:idx
	    let l:css_decl[l:idx] = 'font-weight: normal;'
	else
	    let l:css_decl = add(l:css_decl, 'font-weight: normal;')
	endif
	let l:idx = match(l:css_decl, 'font-style')
	if 0 <= l:idx
	    let l:css_decl[l:idx] = 'font-style: normal;'
	else
	    let l:css_decl = add(l:css_decl, 'font-style: normal;')
	endif
	let l:idx = match(l:css_decl, 'text-decoration')
	if 0 <= l:idx
	    let l:css_decl[l:idx] = 'text-decoration: none;'
	else
	    let l:css_decl = add(l:css_decl, 'text-decoration: none;')
	endif
    endif

    if get(a:hiattr, 'lum')
" что‐то делаем
    endif

    if get(a:hiattr, 'ncomb')
" что‐то делаем
    endif
    let l:css_decl[0] = '{' .. l:css_decl[0]
    let l:css_decl[-1] = l:css_decl[-1] .. '}'

    return l:css_decl
endfunction




function Main()
    call s:HiGroups2Buf()
    if bufexists('Tmp_colo2css')
	let s:is_norm = 1
	for l:grpname in s:init_grp
"	    echo 'grpname ' l:grpname
" Т. к. функция GetLnkGrp работает с регистром "l, то прдеварительно
" подгатавливаем его. Как в вызваемую функцию передавать наименование регистра и
" чтобы она с ним работала именно как с регистром, я так и не победил. Бля, тупею.
	    let @l = ''
"	    echo 'reg l '@l
	    let l = s:GetLnkGrp(l:grpname)
"	    echo 'l ' l 
"	    echo 'reg l '@l
	    if !empty(l)
"	    let s:css_rule = insert(s:css_rule, s:GetLnkGrp(l:grpname))
"		let s:css_rule = l
	    call insert(s:css_rule, @L)
	    endif
"	    echo 'css_rule lnk ' s:css_rule
	    let @l = ''
	    execute 'normal gg'
	    let l:fndlnr = search('^\<' .. l:grpname .. '\>', 'W', line("$"))
"	    echo 'fndlnr ' l:fndlnr
	    if 0 < l:fndlnr
		if search('links to ', 'cznW', l:fndlnr) != l:fndlnr 
		    if empty(s:css_rule)
			call insert(s:css_rule, s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)
"		    let s:css_rule = insert(s:css_rule, (s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. s:css_rule), 0)
"		    let s:css_rule[0] = s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. s:css_rule[0]
			else
			    let s:css_rule[0] = s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. s:css_rule[0]
			endif
"		    echo 'css_rule0 ' s:css_rule[0]
"		    echo 'css_rule all ' s:css_rule
"		    call map(s:css_rule[0], '"." .. v:val .. ","')
"		    echo 'css_rule0 after map ' s:css_rule[0]
		    call s:ParseHiArgs(l:fndlnr)
"		    echo 'hiattr ' s:hi_attr
		    execute l:fndlnr'delete'
		    if type(0) != type(s:hi_attr) && !empty(s:hi_attr)
			let s:css_rule += s:HiAttr2CssDecl(s:hi_attr)
		    endif
		    call add(g:css_entries, s:css_rule)
		    let s:css_rule = []
		    let s:is_norm = 0
		endif
	    endif
	endfor
    endif
"echo s:css_rule
echo g:css_entries
endfunction








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
	    echo 'csssel after lnk ' l:csssel
	    if !empty(l:csssel) && type(0) != type(l:csssel)
" По‐хорошему, при группировании селекторов, у последнего члена нежелательна запятая
		let l:csssel = substitute(l:csssel, '\(\w\+\)', '\=("." .. submatch(1) .. ",")', 'g')
		echo 'csssel after subs ' l:csssel
		call insert(l:cssrul, l:csssel)
	    endif
	    call cursor(1,1)
	    let l:fndlnr = search('^\<' .. l:grpname .. '\>', 'W', line("$"))
	    if 0 < l:fndlnr
" Смотрим, что корневая группа не ссылается на другую группу, которую мы ещё не
" обработали
		if search('links to ', 'cznW', l:fndlnr) != l:fndlnr 
		    if empty(l:cssrul)
" У этой группы нет ссылающихся на неё других групп
"			call insert(l:cssrul, '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)
			call insert(l:cssrul, s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)
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
"	    echo 'grpname ' l:grpname
" Т. к. функция GetLnkGrp работает с регистром "l, то прдеварительно
" подгатавливаем его. Как в вызваемую функцию передавать наименование регистра и
" чтобы она с ним работала именно как с регистром, я так и не победил. Бля, тупею.
	    let @l = ''
	    let l:csssel = s:GetLnkGrp(l:grpname)
"	    echo 'csssel after lnk ' l:csssel
	    if !empty(l:csssel) && type(0) != type(l:csssel)
" По‐хорошему, при группировании селекторов, у последнего члена нежелательна запятая
"		let l:csssel = substitute(l:csssel, '\(\w\+\)', '\=("." .. submatch(1) .. ",")', 'g')
		let l:csssel = substitute(l:csssel, '\(\w\+\)', '.\1,', 'g')
"		echo 'csssel after subs ' l:csssel
		call insert(l:cssrul, l:csssel)
"		echo 'cssrul[] lnkgrp' l:cssrul
	    endif
	    call cursor(1,1)
	    let l:fndlnr = search('^\<' .. l:grpname .. '\>', 'cW', line("$"))
"	    echo 'fndlnr ' l:fndlnr
	    if 0 < l:fndlnr
" Смотрим, что корневая группа не ссылается на другую группу, которую мы ещё не
" обработали
		if search('links to ', 'cznW', l:fndlnr) != l:fndlnr 
		    if empty(l:cssrul)
" У этой группы нет ссылающихся на неё других групп
			call insert(l:cssrul, '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)
"			call insert(l:cssrul, s:GetEntry(0, l:fndlnr, 1, 0, 'iw'), 0)
"			echo 'cssrul[] grpnm withoff lnkgr' l:cssrul
		    else
			let l:cssrul[0] = '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw') .. ',' .. l:cssrul[0]
"			echo 'cssrul[] grpnm with lnkgr' l:cssrul
		    endif
"		    call s:ParseHiArgs(l:fndlnr)
		    let l:hiattr = s:ParseHiArgs(l:fndlnr)
"		    echo 'hiattr ' l:hiattr
		    if !empty(l:hiattr) && type(0) != type(l:hiattr)
			let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
"			echo 'cssdecl ' l:cssdecl
			if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
			    let l:cssrul += l:cssdecl
"			    echo 'cssrul+cssdecl' l:cssrul
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
	let l:cssrul = []
	let s:is_norm = 0
	endfor
"	echo 'grpname ' l:grpname
	if line('$') != 1
	    while line('$') != 1
		call cursor(1,1)
		let l:grpname = s:GetEntry(0, 1, 1, 0, 'iw')
		if !empty(l:grpname)
		    let @l = ''
		    let l:csssel = s:GetLnkGrp(l:grpname)
		    if !empty(l:csssel) && type(0) != type(l:csssel)



"	    endwhile
    endif
"echo s:css_rule
echo s:css_entries
endfunction



" Это работало в прошлый раз
function Main()
"    call s:HiGroups2Buf()
    if bufexists('Tmp_colo2css')
	set more
	let l:fndlnr = ''
	let l:cssrule = []
" При первом проходе цикла должны быть определены глобальные переменные
" значениями из группы «Normal». Также эта группа имеет некоторые отличия от
" других грпп, которые надо учитывать
	let s:is_norm = 1
	for l:grpname in s:init_grp
"	    echo ' '
"	    echo 'grpname for def ' l:grpname
	    let l:csssel = s:HiGrpNm2CssSel(l:grpname)
"	    echo 'csssel for def ' l:csssel
	    if !empty(l:csssel) && type(0) != type(l:csssel)
		call insert(l:cssrule, l:csssel)
"		echo 'cssrule for def ' l:cssrule
"		call cursor(1,1)
		call setpos('.', [0, 1, 1, 0])
		let l:fndlnr = search('^\<' .. l:grpname .. '\>', 'cW', line('$'))
"		echo 'fndlnr for def ' l:fndlnr
		if 0 < l:fndlnr
		    let l:hiattr = s:ParseHiArgs(l:fndlnr)
	    call deletebufline('Tmp_colo2css', l:fndlnr)
"		    echo 'hiattr for def ' l:hiattr
		    if !empty(l:hiattr) && type(0) != type(l:hiattr)
			let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
"			echo 'cssdecl for def ' l:cssdecl
			if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
			    let l:cssrule += l:cssdecl
"			    call add(s:css_entries, l:cssrule)
			    call add(g:css_entries, l:cssrule)
			endif
		    endif
		endif
	    endif
"	    execute l:fndlnr'delete'

"	    call deletebufline('Tmp_colo2css', l:fndlnr)
" Группа «Normal» может быть только одна, обнуляем этот признак после первого (и
" всех последующих) проходов цикла
	let s:is_norm = 0
	let l:cssrule = []
	endfor
"	    while line('$') != 1 && getline(1) != ""
	    while getline(1) != ""
		let l:cssrule = []
		call cursor(1,1)
		let l:grpname = s:GetEntry(0, 1, 1, 0, 'iw')
"		echo ' '
"		echo 'grpname for not def ' l:grpname
		if !empty(l:grpname)
		    let l:csssel = s:HiGrpNm2CssSel(l:grpname)
"		    echo 'csssel for not def ' l:csssel
		    if !empty(l:csssel) && type(0) != type(l:csssel)
			call insert(l:cssrule, l:csssel)
"			echo 'cssrule for not def ' l:cssrule
			call cursor(1,1)
			let l:fndlnr = search('^\<' .. l:grpname .. '\>', 'cW', line('$'))
"			echo 'fndlnr for not def ' l:fndlnr
			if 0 < l:fndlnr
			    let l:hiattr = s:ParseHiArgs(l:fndlnr)
	    call deletebufline('Tmp_colo2css', l:fndlnr)
"			    echo 'hiattr for not def ' l:hiattr
			    if !empty(l:hiattr) && type(0) != type(l:hiattr)
				let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
"				echo 'cssdecl for not def ' l:cssdecl
				if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
				    let l:cssrule += l:cssdecl
"				    call add(s:css_entries, l:cssrule)
				    call add(g:css_entries, l:cssrule)
				endif
			    endif
			endif
		    endif
"		    execute l:fndlnr'delete'
"		    let l:cssruele = []
		endif
"		execute l:fndlnr'delete'
		let l:cssruele = []
	    endwhile




    endif
"echo s:css_rule
"echo s:css_entries
echo g:css_entries
"unlet s:css_entries
endfunction
