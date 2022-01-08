" BrightColo.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.0.4
" Description:	уменьшение или увеличение яркости (или насыщенности) цвета
"		decrease or increase the brightness (or saturation) of a color
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





function s:BrightColo(hexcolo, prcnt, lord)
  let l:hexcolo = ''
  if !empty(a:hexcolo)
" Обрабатывается только шестнадцатеричное значение цвета в модели RGB. Удалим
" приставки, если они существуют.
    let l:colo = trim(a:hexcolo, '#', 1)
    let l:colo = substitute(a:hexcolo, '\c^0x', '', '')
  else
    return -1
  endif
" Значение не должно выходить за границы диапазона.
  let l:prcnt = (100 < a:prcnt ? 100 : 0 > a:prcnt ? 0 : a:prcnt)
" Тип возвращаемого значения функции RGB2HSB() является списоком (массивом).
  let l:hsb = s:RGB2HSB(l:colo)
  if 'l' ==? a:lord
" При значениях близких к максимальной яркости уменьшаем насыщенность
" (высветляем) цвет.
    if 99 <= l:hsb[2]
      let l:hsb[1] = l:hsb[1] - a:prcnt
    else
      let l:hsb[2] = l:hsb[2] + a:prcnt
    endif
  elseif 'd' ==? a:lord
" При значениях близких к минимальной яркости увеличиваем насыщенность
" (затемняем) цвет.
    if 1 >= l:hsb[2]
      let l:hsb[1] += l:prcnt
    else
      let l:hsb[2] -= l:prcnt
    endif
  endif
  let l:hsb[1] = (100 < l:hsb[1] ? 100 : 0 > l:hsb[1] ? 0 : l:hsb[1])
  let l:hsb[2] = (100 < l:hsb[2] ? 100 : 0 > l:hsb[2] ? 0 : l:hsb[2])
" Тип возвращаемого значения функции HSB2RGB() является списоком (массивом).
  let l:rgb = s:HSB2RGB(l:hsb[0], l:hsb[1], l:hsb[2])
  let @d = ''
  for l:cc in l:rgb
    let @d = s:Dec2Hex(l:cc)
    if -1 == (@d+0)
      return -1
    endif
    let l:hexcolo = l:hexcolo .. @d
  endfor
  return '#' .. l:hexcolo
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file BrightColo.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
