" colo2css.vim
" Maintainer:	Restorer
" Last change:	08 Nov 21
" Version:	0.9.19
" Description:	преобразование файла цветовой схемы в CSS-файл
"		converting colorscheme file to CSS file



if has('user_commands') && !exists(':TOcss')
    command! -nargs=0 TOcss call s:MainColo2Css()
endif
"if !exists(":IScss") && has("user_commands")
"  command -nargs=0 IScss :call s:MainColoCss()
"endif
"


" Цвета, которые отсутствуют в файле rgb.txt. Взято из файла src\term.c 
let s:not_rgb =
    \ [['darkyellow','8B8B00'],['lightmagenta','FF8BFF'],['lightred','FF8B8B']]

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

" ПРАВЬ: если изменяется количиство или порядок членов массива, то ОБЯЗАТЕЛЬНО
" исправить в коде, который использует этот массив
let s:fnt_size = ['h', 'w', 'W']

let s:spec_attr = [['bold', 'wght'], ['italic', 'itlc'],
    \ ['underline', 'undlne'], ['undercurl', 'undcrl'],
    \ ['reverse', 'rvrs'], ['inverse', 'rvrs'],
    \ ['strikethrough', 'skthro'], ['NONE', 'rset'],
    \ ['standout', 'lum'], ['nocombine', 'ncomb']]

let s:hi_args = ['gui', 'guifg', 'guibg', 'guisp', 'font']

" Группы подсветки, используемые по умолчанию. Взято из *highlight-default*
" Группа «Normal» должна быть первой, т. к. это будут начальные настройки CSS
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


"let s:init_grp = ['Normal', 'EndOfBuffer', 'NonText', 'QuickFixLine', 'Search']

" Общие переменные
let s:nm_tmp_buf = 'Tmp_Colo2CSS'
let s:is_norm = ''
let s:bg_norm = ''
let s:fg_norm = ''
let s:cmmn_grp = ''
let s:css_head = []





" Честно подсмотрено в hitest.vim
function s:HiGroups2Buf()
" Задаём необходимые нам значения параметров
    set hidden lazyredraw nomore report=99999 shortmess=aAoOsStTW nowrapscan
    set nospell whichwrap&

" Считываем в регистр "h вывод команды `highlight`
    redir @h
    silent highlight
    redir END

" Создаём новое окно, если текущее окно содержит какой‐нибудь текст
" НАДО: в окончательном варианте это удалить, т. к. не потребуется и
"    сделано здесь для целей тестирования
"   if line("$") != 1 || getline(1) != ""
"	new
"    endif

" Создаём временный буфер
    execute 'edit ' .. s:nm_tmp_buf

" И устанавливаем для него необходимые локальные параметры textwidth=0 
    setlocal noautoindent noexpandtab formatoptions=""
    setlocal noswapfile
    setlocal buftype=nofile
    let &textwidth=&columns

" Помещаем в созданный буфер содержимое регистра "h
    put h

" Удалим те группы, которые не заданы в этой цветовой схеме
    silent! global/ cleared$/delete

" Также удаляем символы «xxx » в выводе команды `:highlight`
    %substitute/xxx //e

" Объединяем строки с наименованием группы и ссылкой на группу, если есть перенос
    silent! global/^\s*links to \w\+/.-1join

" Для ускорения поиска удаляем пустые строки
    silent! global/^\s*$/delete
    
" Обрабатывать будем только атрибуты для gui. Удалим другие, чтобы не мешались
" под рукой
"    silent! %substitute/\<term=\w\+\s//e
"    silent! %substitute/\<term=\w\+,\w\+\s//e
"    silent! %substitute/\<start=\w\+\s//e 
"    silent! %substitute/\<stop=\w\+\s//e 
"    silent! %substitute/\<cterm=\w\+\s//e
"    silent! %substitute/\<cterm=\w\+,\w\+\s//e
"    silent! %substitute/\<ctermfg=\w\+\s//e 
"    silent! %substitute/\<ctermbg=\w\+\s//e 
"    silent! %substitute/\<ctermul=\w\+\s//e 
endfunction



function s:GetEntry(bnr, lnr, colnr, offset, motion)
    let @e = ''
    if !setpos('.', [a:bnr, a:lnr, a:colnr, a:offset])
	execute 'normal "ey' .. a:motion
    endif
    return getreg('e')
endfunction



function s:GetLnkGrp(grpname)
    if !empty(a:grpname)
	if !cursor(1,1)
	    let l:srchpat = 'links to\s\+' .. a:grpname .. '$'
	    let l:srchflgs = 'cW'
	    let l:lnkgrpnm = ''
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
" начальную группу
		    call s:GetLnkGrp(l:lnkgrpnm)
		endif
	    let l:lnr = l:fndlnr
	    endwhile
	return @L
	endif
    endif
    return -1
endfunction



function s:Dec2Hex(str)
" Так, конечно, делать не надо. Такие читы до добра не доводят!
"   let l:hex=printf("%X", a:str)
"   return l:hex
    let l:hexdig=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
    let l:hex = ''
    let l:num=str2nr(a:str, 10)
    if 0 == l:num
	return 0 .. l:num
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
	    let l:rgbcolo = ""
	    if has('win32')
		if 0 <= stridx(toupper(a:colostr), 'SYS_', 0)
" Гулять, так гулять... Будь внимателен с кавычками, наклонной чертой и проч. 
" спецсимволами, экранируй их правильно.
		    let l:rgbcolo =
			\ system("powershell Get-ItemProperty -Path 'Registry::HKCU\\Control Panel\\Colors' -Name "
			\ .. s:winsys_colo[toupper(a:colostr)][0]
			\ .. " ^| Select-Object -ExpandProperty "
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
	    if empty(l:rgbcolo)
		for l:nrgb in s:not_rgb
		    if a:colostr ==? l:nrgb[0]
			return l:nrgb[1]
		    endif
		endfor
	    else
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
	if '#' == a:colo[0:0]
	    return a:colo
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



function s:GetInitFont()
    let @t = ''
    let @t = getfontname()
    if empty(@t)
	let @t = &guifont
	if !empty(@t)
" Шаблон поиска не очень хороший
	    let l:com = match(@t, '\w,')
	    if 0 < l:com
		let @t = strpart(@t, 0, l:com)
	    endif
	endif
    endif
    return getreg('t')
endfunction


function s:ParseFont(fntval)
    if !empty(a:fntval)
	let l:fnt = {}
	if 'NONE' ==? a:fntval
	    let l:hifnt = s:GetInitFont()
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
" Матрицу значений (записывается в квадратных скобках) не обрабатываем
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



function s:ParseHiArgs(grpname)
    if !empty(a:grpname)
	let l:hiattr = {}
	let l:fndlnr = ''
	call setpos('.', [0,1,1,0])
	let l:fndlnr = search('^\<' .. a:grpname .. '\>', 'cW', line('$'))
	if 0 < l:fndlnr
	    let l:str = getline(l:fndlnr)
	    for l:hiarg in s:hi_args
		let @s = ''
		if 'gui' == l:hiarg
		    let l:pos = matchend(l:str, l:hiarg .. '=')
		    if 0 <= l:pos
" Если присутствует в строке, копируем значение как СЛОВО до пробельного символа
			let @s = s:GetEntry(0, l:fndlnr, l:pos+1, 0, 'E')
			if !empty(@s)
			    for attr in s:spec_attr
				if 0 <= (stridx(@s, attr[0])) 
" При наличии наименования атрибута из массива, присваиваем значение
" соответствующему наименованию ключа словаря
				    let l:hiattr[attr[1]] = 1
" и удаляем из строки наименование атрибута
				    let @s =
					\ substitute(@s, '\c'..attr[0]..'\%( \|,\)\=', '', '')
				    if empty(@s)
" Завершаем цикл проверки наименований атрибутов, т. к. строка уже пустая
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
			let @s = s:GetEntry(0, l:fndlnr, l:pos+1, 0, 'E')
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
			let @s = s:GetEntry(0, l:fndlnr, l:pos+1, 0, 'g_')
		    elseif s:is_norm
			let @s = s:GetInitFont()
		    endif
		    if !empty(@s)
			let l:fnt = s:ParseFont(@s)
			if !empty(l:fnt) && type(0) != type(l:fnt)
			    let l:hiattr['font'] = l:fnt
			endif
		    endif
		endif
	    endfor
" Обрабатываем ситуацию, когда в цветовой схеме не задана группа «Normal».
" Корневой и универсальный селекторы нужны
" Это поломало многое. Надо переписывать код.
	elseif s:is_norm
	    let l:hiattr['norm'] = 0
	endif
" Всё одно удаляем строку с этой группой, даже если мы не смогли получить её
" свойства, но только если она не ссылается на другие группы
	call deletebufline(s:nm_tmp_buf, l:fndlnr)
	return l:hiattr
    endif
    return -1
endfunction

function s:HiAttr2CssDecl(hiattr)
    if !empty(a:hiattr)
	let l:cssdecl = []
	let l:fnt = {}
	if has_key(a:hiattr, 'font')
	    let l:fnt = a:hiattr['font']
	endif

	if !empty(l:fnt)
" Формируем объявление (декларацию) для шрифта
	    if has_key(l:fnt, 'fntname')
		call add(l:cssdecl,
		    \ 'font-family: "' .. l:fnt['fntname']
		    \ .. '", monospace;')
	    endif
	    if has_key(l:fnt, 'fnthght')
" Для X11 делим на десять. Единицы измерения устанавливаем в пункты (points),
" как указано для шрифта в справке Vim
		call add(l:cssdecl,
		    \ 'font-size: ' .. (has('X11') ?
		    \ l:fnt['fnthght']/10 : l:fnt['fnthght']) .. 'pt;')
	    endif
	    if has_key(l:fnt, 'fntwdt')
" НАДО: составить какую‐то таблиц соответствий для свойств, определённых для X11
" и ключевых слов, определённых в CSS. Не все свойства X11 совпадают с CSS
" НАДО: посмотреть, как Windows высчитывает ширину символов и как это
" соотносится с CSS
		if has('X11')
		    call add(l:cssdecl,
			\ 'font-stretch: '
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
" Обрабатываем ситуацию, когда для группы «Normal» не получен шрифт, или вообще
" отсутствует определнеие этой группы в цветовой схеме
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
" Аналогично предыдущему с насыщенностью, но лучше пока оставим. Чревато
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
		call add(l:cssdecl, 'background-color: transparent;')
	    elseif 'bg' ==? l:bgc && !s:is_norm
		if '' != s:bg_norm
		    call add(l:cssdecl, 'background-color: ' .. s:bg_norm .. ';')
		else
		    return -1
		endif
	    elseif 'fg' ==? l:bgc && !s:is_norm
		if '' != s:fg_norm
		    call add(l:cssdecl, 'background-color: ' .. s:fg_norm .. ';')
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
	elseif s:is_norm
	    call add(l:cssdecl, 'background-color: transparent;')
" НАДО: посмотреть, как в Vim это реализовано. Прикинуть, как вытаскивать
" системные значения. Для Windows я примерно представляю, а вот в других не очень
	    let s:bg_norm = '#FFFFFF'
	endif

	if has_key(a:hiattr, 'fgco')
" Чтобы каждый раз не дёргать эту функцию
	    let l:fgc = get(a:hiattr, 'fgco')
	    if 'NONE' ==? l:fgc && !s:is_norm
		call add(l:cssdecl, 'color: inherit;')
	    elseif 'bg' ==? l:fgc && !s:is_norm
		if '' != s:bg_norm
		    call add(l:cssdecl, 'color: ' .. s:bg_norm .. ';')
		else
		    return -1
		endif
	    elseif 'fg' ==? l:fgc && !s:is_norm
		if '' != s:fg_norm
		    call add(l:cssdecl, 'color: ' .. s:fg_norm .. ';')
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
	elseif s:is_norm
	    call add(l:cssdecl, 'color: inherit;')
" НАДО: посмотреть, как в Vim это реализовано. Прикинуть, как вытаскивать
" системные значения. Для Windows я примерно представляю, а вот в других не очень
	    let s:fg_norm = '#000000'
	endif

	if !empty(l:fnt)
	    if get(l:fnt, 'fntundr')
		call add(l:cssdecl, 'text-decoration: underline;')
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
" Тоже, что и раньше. В Windows, как правило, только одно свойство возвращается
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
" Тоже и с этим объявлением и поддержкой ранними обозревателями страниц Интернет
	    if 'NONE' ==? l:tdc
		call add(l:cssdecl,
		    \ '-moz-text-decoration-color: currentColor;'
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
		call add(l:cssdecl,
		    \ '-moz-text-decoration-color: ' .. l:tdc .. ';'
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
" Если цвет переднего плана определён ранее, то сохраняем индекс его объявления
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
" плана, а цвет заднего плана для элемента — заданное значение
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



function s:HiGrpNm2CssSel(grpname)
    if !empty(a:grpname)
	let l:csssel = ''
	let l:fndlnr = ''
" Т. к. функция GetLnkGrp работает с регистром "l, то предварительно
" подготавливаем его. Как в вызываемую функцию передавать наименование регистра и
" чтобы она с ним работала именно как с регистром, я так и не победил
	let @l = ''
	let l:lnkgrp = s:GetLnkGrp(a:grpname)
	if !empty(l:lnkgrp) && type(0) != type(l:lnkgrp)
" По‐хорошему, при группировании селекторов, у последнего члена нежелательна
" запятая. Поэтому, чтобы не городить проверки, далее делаем финт ушами
	    let l:lnkgrp = substitute(l:lnkgrp, '\(\w\+\)', '.\1,', 'g')
	endif
	call setpos('.', [0, 1, 1, 0])
	let l:fndlnr = search('^\<' .. a:grpname .. '\>', 'cW', line('$'))
	if 0 < l:fndlnr
" Смотрим, что группа не ссылается на другую группу, которую мы ещё не обработали
" Тут вылезла забавная коллизия. Если эта запись не наименование группы из
" массива, т. е. другого наименования группы на следующем шаге не будет, то
" получим вечный цикл. Решение см. ниже
	    if search('links to ', 'cnW', l:fndlnr) != l:fndlnr
		if empty(l:lnkgrp)
		    let l:csssel = '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
		elseif type(0) != type(l:lnkgrp)
		    let l:csssel =
			\ '.' .. s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
			\ .. ',' .. l:lnkgrp
		endif
" Нда, вначале добавляем запятые, а потом удаляем... Но так быстрее. В смысле
" проще. Заодно и для группы «Normal» добавим универсальный селектор
		let l:csssel =
		    \ s:is_norm ? trim('*, ' .. l:csssel, ',', 2)
		    \ : trim(l:csssel, ',', 2)
		return l:csssel
	    else
" Не нравится мне это решение. Помимо того, что вводится общая переменная, так
" ещё и изменяется ход выполнения. Да, это обрабатывает следующие ситуации:
" разбор групп, ссылающиеся на группы, которые не обрабатывали (ниже в строке)
" разбор групп, которые ссылаются на несуществующие группы (встретилось в
" Jellibeans и NeoSolarized)
" Но, по‐хорошему, надо менять логику (и так неважную) работы программы
		let s:cmmn_grp =
		    \ (matchlist(getline(l:fndlnr), '\(links to \)\(\w\+\)'))[2]
	    endif
" Обрабатываем ситуацию, когда в цветовой схеме не задана группа «Normal».
" Корневой и универсальный селекторы нужны
" Это поломало многое. Надо переписывать код.
	elseif s:is_norm
	    let l:csssel = '*, .Normal'
	    return l:csssel
	endif
    endif
	return -1
endfunction



function s:Hi2Css(grpname)
    if !empty(a:grpname)
	let l:cssrule = []
	let l:csssel = s:HiGrpNm2CssSel(a:grpname)
	if !empty(l:csssel) && type(0) != type(l:csssel)
	    call insert(l:cssrule, l:csssel)
	    let l:hiattr = s:ParseHiArgs(a:grpname)
	    if !empty(l:hiattr) && type(0) != type(l:hiattr)
		let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
		if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
		    let l:cssrule += l:cssdecl
		endif
	    endif
	endif
	return l:cssrule
    endif
    return -1
endfunction


if has('user_commands') && !exists(':TOcss')
    command! -nargs=0 TOcss call s:Colo2Css()
endif

function s:MainColo2Css()
    call s:HiGroups2Buf()
    if bufexists(s:nm_tmp_buf)
" При первом проходе цикла должны быть определены глобальные переменные
" значениями из группы «Normal». Также эта группа имеет некоторые отличия от
" других групп, которые надо учитывать
	let l:cssentries = []
	let s:is_norm = 1
	for l:grpname in s:init_grp
" Ещё одна лишняя проверка. Когда есть ссылка на группу, которая ниже. См. далее
	    if l:grpname ==? s:cmmn_grp
		let s:cmmn_grp = ''
	    endif
	    let l:cssrule = s:Hi2Css(l:grpname)
	    if !empty(l:cssrule) && type(0) != type(l:cssrule)
		call add(l:cssentries, l:cssrule)
	    endif
" Группа «Normal» может быть только одна, обнулим этот признак после первого (и
" всех последующих) проходов цикла
	let s:is_norm = 0
	endfor
	while getline(1) != ""
" Это не очень красивый трюк. Сделано на случай, если текущая группа ссылается
" на другую группу, которая ещё не обработана. Или если группа ссылается на
" несуществующую группу. См. функцию s:HiGrpNm2CssSel. А вообще
" НАДО: сделать нормальную обработку кодов ошибок.
	    if '' != s:cmmn_grp
		let l:cssrule = s:Hi2Css(s:cmmn_grp)
		let s:cmmn_grp = ''
	    else
		let l:grpname = s:GetEntry(0, line('.'), 1, 0, 'iw')
		if !empty(l:grpname)
		    let l:cssrule = s:Hi2Css(l:grpname)
		endif
	    endif
	    if !empty(l:cssrule) && type(0) != type(l:cssrule)
		call add(l:cssentries, l:cssrule)
	    endif
	endwhile
	if !empty(l:cssentries)

	    call add(s:css_head,
		\ '/* Этот CSS-файл создан в версии программы Vim '
		\ .. v:version/100 .. '.' .. v:version%100 .. '.'
		\ .. substitute(v:versionlong, v:version, '', '') ..' */')
		"\ .. v:versionlong % float2nr(pow(10, (len(v:versionlong)-len(v:version)))) .. ' */')
	    call add(s:css_head,
		\ '/* из файла цветовой схемы «'
		\ .. trim(execute('colorscheme')) .. '» */')
	    call add(s:css_head,
		\ '/* Для этого был использован подключаемый модуль «colo2css.vim» */')
	    call add(s:css_head, ' ')


" Нужен католог, куда разрешено писать пользователю
	    let l:wrtdir = getenv('HOME')
	    if v:null == l:wrtdir
		let l:wrtdir = (getenv('MYVIMRC')->fnamemodify(':p:h'))
	    endif
	    if exists('*mkdir')
		if !isdirectory(l:wrtdir .. '/Colo2CSS')
		    call mkdir(l:wrtdir .. '/Colo2CSS', '', '')
		endif
		call chdir(l:wrtdir .. '/Colo2CSS')
	    endif


	    let l:flnm = trim(execute('colorscheme') .. '.css')
	    call writefile(map(s:css_head, 'v:val .. ""'), l:flnm)
	    for l:cssln in l:cssentries
		call writefile(map(l:cssln, 'v:val .. ""'), l:flnm, 'a')
"		call append('$', l:cssln)
	    endfor
"	    execute 'saveas ++ff=dos ++enc=utf-8 ' .. trim(execute('colorscheme')) .. '.css'
	    bw!
	endif
    else
	return -1
    endif
    call s:CleanUp()
endfunction



function s:CleanUp()
    unlet s:not_rgb s:winsys_colo s:fnt_size s:spec_attr s:hi_args s:init_grp
    unlet s:nm_tmp_buf s:is_norm s:bg_norm s:fg_norm s:cmmn_grp s:css_head
    delfunction s:HiGroups2Buf
    delfunction s:GetEntry
    delfunction s:GetLnkGrp
    delfunction s:Dec2Hex
    delfunction s:ColoStr2ColoNum
    delfunction s:GetColor
    delfunction s:GetInitFont
    delfunction s:ParseFont
    delfunction s:ParseHiArgs
    delfunction s:HiAttr2CssDecl
    delfunction s:HiGrpNm2CssSel
    delfunction s:Hi2Css
"    delfunction s:MainColo2Css
"    delfunction s:CleanUp
"return | delfunction s:CleanUp
endfunction

"if has('user_commands') && !exists(':TOcss')
"    command! -nargs=0 TOcss call g:MainColo2Css()
"endif

"call s:MainColo2Css()

"unlet s:not_rgb s:winsys_colo s:fnt_size s:spec_attr s:hi_args s:init_grp
"unlet s:nm_tmp_buf s:is_norm s:bg_norm s:fg_norm s:cmmn_grp s:css_head
"delfunction s:HiGroups2Buf
"delfunction s:GetEntry
"delfunction s:GetLnkGrp
"delfunction s:Dec2Hex
"delfunction s:ColoStr2ColoNum
"delfunction s:GetColor
"delfunction s:GetInitFont
"delfunction s:ParseFont
"delfunction s:ParseHiArgs
"delfunction s:HiAttr2CssDecl
"delfunction s:HiGrpNm2CssSel
"delfunction s:Hi2Css
"delfunction g:MainColo2Css

" vim: ff=dos:fenc=utf-8:tw=80:sw=4:ft=vim
