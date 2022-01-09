" ParseFont.vim		vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	09 Jan 2022
" Version:	1.3.0
" Description:	разбор значений заданного шрифта для групп подсветки
"		parsing the values of a given font for highlighting groups
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





const s:FNT_SIZE = ['h', 'w', 'W']



function ParseFont(fntval)
  if !empty(a:fntval)
    let l:fnt = {}
    if 'NONE' ==? a:fntval
      let l:hifnt = s:GetInitFont()
    else
      let l:hifnt = a:fntval
    endif
" *gui-font* *setting-guifont*
    if has('gui_win32')
" На всякий случай. Вдруг кто будет экранировать пробелы в наименовании шрифта
" обратной наклонной чертой
      let l:hifnt = substitute(l:hifnt, '\', '', 'g')
      let l:cln = stridx(l:hifnt, ':')
      if 0 > l:cln
" Шрифт может быть определён только наименованием, как только что убедились.
	return l:fnt['fntname'] = tr(l:hifnt, '_', ' ')
      elseif 0 < l:cln
	let l:fnt['fntname'] = tr(l:hifnt[0:l:cln-1], '_', ' ')
      endif
      for l:fntsze in s:FNT_SIZE
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
    elseif has('gui_gtk2') || has('gui_gtk3')
      let l:hifnt = substitute(l:hifnt, '\', '', 'g')
      let l:fnt['fntname'] = substitute(l:hifnt, '\s\+\d\+$', '', '')
      let l:sze = trim(matchstr(l:hifnt, '\s\d\+$'), ' ', 1)
      if !empty(l:sze)
	let l:fnt['fnthght'] = l:sze
      endif
      return l:fnt
" *gui-font* *setting-guifont* *fontset* *xfontset*
    elseif has('X11')
" *XLFD*
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
      if 0 > l:cln
	return l:fnt['fntname'] = l:hifnt
      elseif 0 < l:cln
	let l:fnt['fntname'] = l:hifnt[0:l:cln-1]
      endif
      let l:sze = matchlist(l:fnt, '\C\(:' ..s:FNT_SIZE[0]..'\)\(\d\{1,}\)')
      if !empty(l:sze)
	let l:fnt['fnthght'] = l:sze[2]
      endif
      return l:fnt
    endif
  endif
  return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file ParseFont.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
