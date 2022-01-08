" RGB2HSB.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.0.2
" Description:	преобразование шестнадцатеричного представления цвета модели RGB
"		в значения цветовой модели HSB
"		converting hexadecimal RGB model color representation to HSB
"		model color values
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



" https://ru.wikipedia.org/wiki/HSV_(%D1%86%D0%B2%D0%B5%D1%82%D0%BE%D0%B2%D0%B0%D1%8F_%D0%BC%D0%BE%D0%B4%D0%B5%D0%BB%D1%8C)#RGB_%E2%86%92_HSV
" https://www.cs.rit.edu/~ncs/color/t_convert.html
function s:RGB2HSB(hexcolo)
" Проверка входных параметров
  if !empty(a:hexcolo) && (6 == len(a:hexcolo))
    let l:rr = str2nr(a:hexcolo[0:1], 16)
    let l:gg = str2nr(a:hexcolo[2:3], 16)
    let l:bb = str2nr(a:hexcolo[4:5], 16)
    let l:max = max([l:rr, l:gg, l:bb])
    let l:min = min([l:rr, l:gg, l:bb])
" Приводим к диапазону значений [0,1] и одновременно преобразуем в тип float.
    let l:rr /= 255.0
    let l:gg /= 255.0
    let l:bb /= 255.0
    let l:max /= 255.0
    let l:min /= 255.0
    let l:dlt = l:max - l:min
    if l:max != l:min
      if l:max == l:rr
	let l:h = (l:gg - l:bb) / l:dlt + (l:gg < l:bb ? 6 : 0)
      elseif l:max == l:gg
	let l:h = (l:bb - l:rr) / l:dlt + 2
      elseif l:max == l:bb
	let l:h = (l:rr - l:gg) / l:dlt + 4
      endif
      let l:h = float2nr(ceil(l:h * 60))
    else
      let l:h = 0
    endif
    if 0 == l:max
      let l:h = 0
      let l:s = 0
    else
      let l:s = float2nr((l:dlt / l:max) * 100)
    endif
    let l:b = float2nr(l:max * 100)
" Диапазон значений элементов l:h=|0...360|, l:s=|0...100|, l:b=|0...100| в
" возвращаемом массиве (списке).
    return [l:h, l:s, l:b]
  else
    return -1
  endif
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file RGB2HSB.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
