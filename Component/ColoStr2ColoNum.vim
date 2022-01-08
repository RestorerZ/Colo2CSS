" ColoStr2ColoNum.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.4.10
" Description:	преобразует цвет, указанный его наименованием в
"		шестнадцатеричное представление модели RGB
"		converts the color specified by its name to the hexadecimal
"		representation of the RGB model
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



" Цвета, которые отсутствуют в файле rgb.txt. Взято из файла src\term.c
const s:NOT_RGB =
  \ [['darkyellow','8B8B00'],['lightmagenta','FF8BFF'],['lightred','FF8B8B']]


" *win32-colors*
" https://russianblogs.com/article/8427240475/
" http://rusproject.narod.ru/winapi/g/getsyscolor.html
" https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
const s:WINSYS_COLO = {
  \ 'SYS_SCROLLBAR':['Scrollbar', 'COLOR_SCROLLBAR', 0],
  \ 'SYS_BACKGROUND':['Background', 'COLOR_BACKGROUND', 1],
  \ 'SYS_DESKTOP':['Background', 'COLOR_DESKTOP', 1],
  \ 'SYS_ACTIVECAPTION':['ActiveTitle', 'COLOR_ACTIVECAPTION', 2],
  \ 'SYS_INACTIVECAPTION':['InactiveTitle', 'COLOR_INACTIVECAPTION', 3],
  \ 'SYS_MENU':['Menu', 'COLOR_MENU', 4],
  \ 'SYS_WINDOW':['Window', 'COLOR_WINDOW', 5],
  \ 'SYS_WINDOWFRAME':['WindowFrame', 'COLOR_WINDOWFRAME', 6],
  \ 'SYS_MENUTEXT':['MenuText', 'COLOR_MENUTEXT', 7],
  \ 'SYS_WINDOWTEXT':['WindowText', 'COLOR_WINDOWTEXT', 8],
  \ 'SYS_CAPTIONTEXT':['TitleText', 'COLOR_CAPTIONTEXT', 9],
  \ 'SYS_ACTIVEBORDER':['ActiveBorder', 'COLOR_ACTIVEBORDER', 10],
  \ 'SYS_INACTIVEBORDER':['InactiveBorder', 'COLOR_INACTIVEBORDER', 11],
  \ 'SYS_APPWORKSPACE':['AppWorkspace', 'COLOR_APPWORKSPACE', 12],
  \ 'SYS_HIGHLIGHT':['Hilight', 'COLOR_HIGHLIGHT', 13],
  \ 'SYS_HIGHLIGHTTEXT':['HilightText', 'COLOR_HIGHLIGHTTEXT', 14],
  \ 'SYS_3DFACE':['ButtonFace', 'COLOR_3DFACE', 15],
  \ 'SYS_BTNFACE':['ButtonFace', 'COLOR_BTNFACE', 15],
  \ 'SYS_3DSHADOW':['ButtonShadow', 'COLOR_3DSHADOW', 16],
  \ 'SYS_BTNSHADOW':['ButtonShadow', 'COLOR_BTNSHADOW', 16],
  \ 'SYS_GRAYTEXT':['GrayText', 'COLOR_GRAYTEXT', 17],
  \ 'SYS_BTNTEXT':['ButtonText', 'COLOR_BTNTEXT', 18],
  \ 'SYS_INACTIVECAPTIONTEXT':['InactiveTitleText', 'COLOR_INACTIVECAPTIONTEXT', 19],
  \ 'SYS_3DHILIGHT':['ButtonHilight', 'COLOR_3DHILIGHT', 20],
  \ 'SYS_3DHIGHLIGHT':['ButtonHilight', 'COLOR_3DHIGHLIGHT', 20],
  \ 'SYS_BTNHILIGHT':['ButtonHilight', 'COLOR_BTNHILIGHT', 20],
  \ 'SYS_BTNHIGHLIGHT':['ButtonHilight', 'COLOR_BTNHIGHLIGHT', 20],
  \ 'SYS_3DDKSHADOW':['ButtonDkShadow', 'COLOR_3DDKSHADOW', 21],
  \ 'SYS_3DLIGHT':['ButtonLight', 'COLOR_3DLIGHT', 22],
  \ 'SYS_INFOTEXT':['InfoText', 'COLOR_INFOTEXT', 23],
  \ 'SYS_INFOBK':['InfoWindow', 'COLOR_INFOBK', 24]
  \ }



function s:ColoStr2ColoNum(colostr)
  if !empty(a:colostr)
    for l:nrgb in s:NOT_RGB
      if a:colostr ==? l:nrgb[0]
	return l:nrgb[1]
      endif
    endfor
" В версии 8.2.3562 появился словарь v:colornames
" Это быстрее, чем искать по внешнему файлу
    if 8023562 <= v:versionlong && exists('v:colornames')
      if has_key(v:colornames, tolower(a:colostr))
" Обрезаем у возвращаемого значения символ диеза. Сделано для однообразия кода,
" ну и функция, судя по названию, должна возвращать число. Символ «#» приклеет
" потом вызывающая функция.
	return toupper(v:colornames[tolower(a:colostr)][1:])
      endif
    endif
    let l:rgbcolo = ''
    if has('win32')
      if 0 <= stridx(toupper(a:colostr), 'SYS_', 0)
" Будь внимателен с кавычками, наклонной чертой и проч. спецсимволами, экранируй
" их правильно.
	let l:rgbcolo = system(
\ "powershell Get-ItemProperty -Path 'Registry::HKCU\\Control Panel\\Colors' -Name "
\ .. s:WINSYS_COLO[toupper(a:colostr)][0] .. " ^| Select-Object -ExpandProperty "
\ .. s:WINSYS_COLO[toupper(a:colostr)][0])
      elseif filereadable($VIMRUNTIME .. '/rgb.txt')
" Не очень просто получается с findstr. Он не помнимает LF как разрыв строки, да
" и с поисковыми шаблонами что‐то... (либо я не умею его готовить)
" Пробуем ещё одну штуковину. Весь это powershell надо, конечно, тестировать и
" тестировать. ХЗ, как будет на других машинах. Надо поднимать ВМ...
	let l:rgbcolo =
	  \ system("powershell Select-String -Path "
	  \ .. $VIMRUNTIME .. "\\rgb.txt -Pattern " .. "'\\t"
	  \ .. a:colostr .. "$'" .. " ^| "
	  \ .. "Select-Object -ExpandProperty Line")
      endif
    elseif has('unix')
      if filereadable($VIMRUNTIME .. '/rgb.txt')
" Буду в виртуалках Windows поднимать, надо что‐нибудь и UNIX-подобное поднять.
	let l:rgbcolo =
	  \ system('grep -i -h -w -e "[[:space:]]' ..a:colostr.. '$" '
	  \ ..$VIMRUNTIME .. '/rgb.txt')
      endif
    endif
    if !empty(l:rgbcolo)
      let l:hexcolo = ''
      let l:rgbcolo = matchstr(l:rgbcolo, '\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
      while !empty(l:rgbcolo)
	let @d = ''
	let @d = matchstr(l:rgbcolo, '^\d\{1,3}')
	let l:rgbcolo = substitute(l:rgbcolo, @d .. '\s*', '', '')
	let @d = s:Dec2Hex(@d)
	if -1 ==(@d+0)
	  return -1
	endif
	let l:hexcolo = l:hexcolo .. @d
      endwhile
      return l:hexcolo
    endif
  endif
  return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file ColoStr2ColoNum.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
