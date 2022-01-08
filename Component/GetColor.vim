" GetColor.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.0.1
" Description:	возвращает шестнадцатеричный код или свециальное обозначение
"		цвета, полученное из значения аргумента команды `highlight`
"		returns the hexadecimal color code or its special name derived
"		from the value of the arguments of the `highlight` command
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



function s:GetColor(coloval)
  if !empty(a:coloval)
    if '#' == a:coloval[0:0]
      return toupper(a:coloval)
    elseif 0 <= stridx(tolower(a:coloval), 'bg') ||
		\ 0 <= stridx(tolower(a:coloval), 'background')
      return 'bg'
    elseif 0 <= stridx(tolower(a:coloval), 'fg') ||
		\ 0 <= stridx(tolower(a:coloval), 'foreground')
      return 'fg'
    elseif 0 <= stridx(toupper(a:coloval), 'NONE')
      return 'NONE'
    elseif 0 <= match(a:coloval, '\w\+')
      let @c = ''
      let @c = s:ColoStr2ColoNum(a:coloval)
      if !empty(@c) && -1 != (@c+0)
	return '#' .. @c
      endif
    endif
  endif
  return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file GetColor.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
