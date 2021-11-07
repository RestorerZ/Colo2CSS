







let s:cssentry = {'selector':[], 'bg':"", 'color':"", 'fnt_stl':"", 'fnt_wgh':"", 'fnt':""}

let s:spec_attr = [['bold', 'wght'], ['italic', 'itlc'],
    \ ['underline', 'undlne'], ['undercurl', 'undcrl'],
    \ ['reverse', 'rvrs'], ['inverse', 'rvrs'],
    \ ['strikethrough', 'skthro'], ['NONE', 'rset'],
    \ ['standout', 'lum'], ['nocombine', 'ncomb']]

let s:hi_args = ['gui', 'guifg', 'guibg', 'guisp', 'font']

let s:fnt_size = ['h', 'w', 'W']

let s:hi_fnt = {}

let s:hi_attr = {}

let s:is_norm = 1

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

function s:GetEntry(bnr, lnr, colnr, offset, motion)
    let @n = ""
    if !setpos('.', [a:bnr, a:lnr, a:colnr, a:offset])
	execute 'normal "ny' .. a:motion
    endif
    return getreg('n')
endfunction


function s:Dec2Hex(str)
" Так, конечно, делать не надо. Такие читы до добра не доводят!
"   let l:hex=printf("%X", a:str)
"   return l:hex
    let l:hexdig=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
    let l:hex = ""
    let l:num=str2nr(a:str, 10)
    if 0 == l:num
	return l:num
    else
	while l:num
	    let l:hex=l:hexdig[l:num%16] .. l:hex
	    let l:num/=16
	endwhile
    endif
    return l:hex
endfunction


function s:ColoStr2ColoNum(colostr)
    if !empty(a:colostr)
	if filereadable($VIMRUNTIME .. '/rgb.txt')
	    let l:rgbcolo = ''
	    if has('win32')
		if 0 <= stridx(toupper(a:colostr), 'SYS_', 0)
" Гулять, так гулять... Будь внимателен с " кавычками, наклонной чертой и проч. 
" спецсимволами, экранируй их правильно.
		    let l:rgbcolo = system(
\ "powershell Get-ItemProperty -Path 'Registry::HKCU\\Control Panel\\Colors' -Name "
\ .. s:winsys_colo[toupper(a:colostr)][0] .. " ^| Select-Object -ExpandProperty "
\ .. s:winsys_colo[toupper(a:colostr)][0])
		else
" Не очень просто получается с findstr. Пробуем ещё одну штуковину. Весь это
" powershell надо, конечно, тестировать и тестировать. ХЗ, как будет на других
" машинах. Надо поднимать ВМ...
		    let l:rgbcolo =
			\ system("powershell Select-String -Path "
			\ .. $VIMRUNTIME .. "\\rgb.txt -Pattern " .. "'\\t"
			\ .. a:colostr .. "$'" .. " ^| "
			\ .. "Select-Object -ExpandProperty Line")
		endif
	    elseif has('unix')
" Буду в виртуалках Windows поднимать, надо что‐нибудь и UNIX-подобное поднять.  
		let l:rgbcolo =
		    \ system('grep -i -h -w -e "[[:space:]]' .. a:colostr .. '$" '
		    \ ..$VIMRUNTIME .. '/rgb.txt')
	    endif
	    if !empty(l:rgbcolo)
		let l:hexcolo = ''
		let l:rgbcolo =
		    \ matchstr(l:rgbcolo, '\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
		while !empty(l:rgbcolo)
		    let @d = ''
		    let @d = matchstr(l:rgbcolo, '\_^\d\{1,3}')
		    let l:rgbcolo = substitute(l:rgbcolo, @d .. '\s*', '', '')
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
"	if '#' == strcharpart(a:colo, 0, 1)
	if '#' == a:colo[0:0]
	    return trim(a:colo)
	elseif 0 <= stridx(tolower(a:colo), 'bg') ||
		    \ 0 <= stridx(tolower(a:colo), 'background')
	    return 'bg'
	elseif 0 <= stridx(tolower(a:colo), 'fg') ||
		    \ 0 <= stridx(tolower(a:colo), 'foreground')
	    return 'fg'
	elseif 0 <= stridx(toupper(a:colo), 'NONE')
	    return 'NONE'
	elseif 0 <= match(a:colo, '\w\+')
	    let @c = ""
	    let @c = s:ColoStr2ColoNum(a:colo)
	    if !empty(@c) && 0 <= @c 
		return '#' .. @c
	    endif
	endif
    endif
    return -1
endfunction


function s:ParseFont(fntval)
    if !empty(a:fntval)
	let l:fnt = {}
	if 'NONE' ==? a:fntval
	    let l:hifnt = getfontname()
	else
	    let l:hifnt = a:fntval
	endif
" *gui-font* *setting-guifont*
	if has ('gui_win32')
" На всякий случай. Вдруг кто будет экранировать пробелы в наименовании шрифта
" обратной наклонной чертой
	    let l:hifnt = substitute(l:hifnt, '\', '', 'g')
	    let l:cln = stridx(l:hifnt, ':')
	    if 0 < l:cln
		let l:fnt['fntname'] = tr(l:hifnt[0:l:cln-1], '_', ' ')
	    elseif 0 > l:cln
		let l:fnt['fntname'] = tr(l:hifnt, '_', ' ')
	    endif
	    for l:fntsze in s:fnt_size
		let l:sze =
		    \ matchlist(
		    \ l:hifnt, '\C\(:'..l:fntsze..'\)\(\d\{1,}\.\{,1}\d\{}\)')
		if !empty(l:sze)
		    if 'h' == l:fntsze
			let l:fnt['fnthght'] = l:sze[2]
	    continue
		    elseif 'w' ==# l:fntsze
			let l:fnt['fntwdth'] = l:sze[2]
	    continue
		    elseif 'W' ==# l:fntsze
			let l:fnt['fntwght'] = l:sze[2]
		    endif
		endif
	    endfor
	    if 0 < stridx(l:hifnt, ':b')
		let l:fnt['fntbold'] = 1
	    endif
	    if 0 < stridx(l:hifnt, ':i')
		let l:fnt['fntitlc'] = 1
	    endif
	    if 0 < stridx(l:hifnt, ':u')
		let l:fnt['fntundr'] = 1
	    endif
	    if 0 < stridx(l:hifnt, ':s')
		let l:fnt['fntsout'] = 1
	    endif
	    return l:fnt
" *gui-font* *setting-guifont*
	elseif has ('gui_gtk2') || has ('gui_gtk3')
	    let l:hifnt = substitute(l:hifnt, '\', '', 'g')
	    let l:fnt['fntname'] = substitute(l:hifnt, '\s\+\d\+$', '', '')
	    let l:fnt['fnthght'] = trim(matchstr(l:hifnt, '\s\d\+$'), ' ', 1)
	    return l:fnt
" *gui-font* *setting-guifont* *fontset* *xfontset*
	elseif has ('X11')
" *XLFD*
" https://www.x.org/releases/X11R7.6/doc/xorg-docs/specs/XLFD/xlfd.html
" http://www.x.org/archive/X11R7.6/doc/xorg-docs/specs/XLFD/xlfd.pdf
" https://dev.abcdef.wiki/wiki/X_logical_font_description
	    let l:hifnt = split(l:hifnt, '-')
	    if !empty(l:hifnt[1]) && '*' != l:hifnt[1]
		let l:fnt['fntname'] = l:hifnt[1]
	    endif
	    if 'bold' ==? l:hifnt[2]
		let l:fnt['fntbold'] = 1
	    endif
	    if 'i' ==? l:hifnt[3] || 'o' ==? l:hifnt[3]
		let l:fnt['fntitlc'] = 1
	    endif
	    if !empty(l:hifnt[4]) && '0' != l:hifnt[4] && '*' != l:hifnt[4]
		let l:fnt['fntwdth'] = l:hifnt[4]
	    endif
" Матрицу значений (записывается в квадраных скобках) не обрабатываем
	    if !empty(l:hifnt[7]) && '[' != l:hifnt[7][0:0] && '*' != l:hifnt[7]
		let l:fnt['fnthght'] = l:hifnt[7]
	    endif
	    return l:fnt
" *gui-font*
	elseif has ('gui_mac')
" ХЗ, как экранируются пробелы в наименовании шрифта на MacOS. Поэтом пробуем
" оба метода: убрать нижнее подчёркивание, как в Win32 и убрать обратную
" наклонную черту, как в GTK
	    let l:hifnt = tr(l:hifnt, '_', ' ')
	    let l:hifnt = substitute(l:hifnt, '\', '', 'g')
	    let l:cln = stridx(l:hifnt, ':')
	    if 0 < l:cln
		let l:fnt['fntname'] = l:hifnt[0:l:cln-1]
	    elseif 0 > l:cln
		let l:fnt['fntname'] = l:hifnt
	    endif
	    let l:sze = 
		\ matchlist(l:fnt, '\C\(:' ..s:fnt_size[0]..'\)\(\d\{1,}\)')
	    if !empty(l:sze)
		let l:fnt['fnthght'] = l:sze[2]
	    endif
	    return l:fnt
	endif
    endif
    return -1
endfunction


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
		    if !empty(@s)
" Если в строке будут символы запятой, заменим их на пробел
			let @s = tr(@s, ',', ' ')
			for attr in s:spec_attr
			    if 0 <= (stridx(@s, attr[0])) 
" При наличии наименования аттрибута из массива, присваиваем значение
" соответствующему наименованию ключа словаря
				let l:hiattr[attr[1]] = 1
" и удаляем из строки наименование аттрибута
				let @s =
				    \ substitute(@s, '\c'..attr[0]..'\s\=', '', '')
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





"unlet s:hi_attr
