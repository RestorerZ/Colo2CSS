" HSB2RGB.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.0.2
" Description:	преобразование значений цветовой модели HSB в значения модели RGB
"		converting HSB color model values to RGB model values
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





" https://ru.wikipedia.org/wiki/HSV_(%D1%86%D0%B2%D0%B5%D1%82%D0%BE%D0%B2%D0%B0%D1%8F_%D0%BC%D0%BE%D0%B4%D0%B5%D0%BB%D1%8C)
" https://cs.stackexchange.com/questions/64549/convert-hsv-to-rgb-colors
function s:HSB2RGB(h, s, b)
" Проверяем допустимые значения входных параметров
  if ((360 >= a:h) && (0 <= a:h)) && ((100 >= a:s) && (0 <= a:s))
	\ && ((100 >= a:b) && (0 <= a:b))
" Если насыщенность == 0, то это оттенки серого цвета.
    if 0 == l:s
"     return [float2nr(a:b * 255), float2nr(a:b * 255), float2nr(a:b * 255)]
      return [
	      \ float2nr(ceil(l:b * 2.55)),
	      \ float2nr(ceil(l:b * 2.55)),
	      \ float2nr(ceil(l:b * 2.55))
	      \ ]
    endif
"   let l:max = l:b
" Приводим к диапазону значений [0,1] и одновременно преобразуем в тип float
    let l:max = l:b / 100.0
"   let l:chrm = l:s * l:b
    let l:chrm = (l:s * l:b) / 10000.0
    let l:min = l:max - l:chrm
    if 300 <= l:h
      let l:hdrtv = (l:h - 360) / 60.0
    elseif 300 > l:h
      let l:hdrtv = l:h / 60.0
    endif
    let l:idx = float2nr(floor(l:hdrtv))
" if 0 <= (l:hdrtv - 0)
    if 0 == l:idx
      let l:rr = l:max
      let l:gg = l:min + l:hdrtv * l:chrm
      let l:bb = l:min
" if 0 > (l:hdrtv - 2)
    elseif 1 == l:idx
      let l:rr = l:min - (l:hdrtv - 2) * l:chrm
      let l:gg = l:max
      let l:bb = l:min
" if 0 <= (l:hdrtv - 2)
    elseif 2 == l:idx
      let l:rr = l:min
      let l:gg = l:max
      let l:bb = l:min + (l:hdrtv - 2) * l:chrm
" if 0 > (l:hdrtv - 4)
    elseif 3 == l:idx
      let l:rr = l:min
      let l:gg = l:min - (l:hdrtv - 4) * l:chrm
      let l:bb = l:max
" if 0 <= (l:hdrtv - 4)
    elseif 4 == l:idx
      let l:rr = l:min + (l:hdrtv - 4) * l:chrm
      let l:gg = l:min
      let l:bb = l:max
" if 0 > (l:hdrtv - 0)
    else
      let l:rr = l:max
      let l:gg = l:min
      let l:bb = l:min - l:hdrtv * l:chrm
    endif
"   return [(l:rr * 2.55) * 100, (l:gg * 2.55) * 100, (l:bb * 2.55) * 100]
    return [
	    \ float2nr(ceil(l:rr * 255)),
	    \ float2nr(ceil(l:gg * 255)),
	    \ float2nr(ceil(l:bb * 255))
	    \ ]
  else
    return -1
  endif
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file HSB2RGB.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
