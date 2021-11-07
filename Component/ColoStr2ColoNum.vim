






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



" Цвета, которые отсутствуют в файле rgb.txt. Взято из файла src\term.c 
let s:notrgb =
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

function ColoStr2ColoNum(colostr)
    if !empty(a:colostr)
	if filereadable($VIMRUNTIME .. '/rgb.txt')
	    let l:rgbcolo = ''
	    if has('win32')
		if 0 <= stridx(toupper(a:colostr), 'SYS_', 0)
" Гулять, так гулять... Будь внимателен с кавычками, наклонной чертой и проч. 
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
	    if empty(l:rgbcolo)
		for l:nrgb in s:notrgb
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

