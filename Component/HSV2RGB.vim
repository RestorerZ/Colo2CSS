" HSV2RGB.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.0.0
" Description:	преобразование значений модели цвета HSB в значения модели RGB
"		converting HSB color model values to RGB model values
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





" https://ru.wikipedia.org/wiki/HSV_(%D1%86%D0%B2%D0%B5%D1%82%D0%BE%D0%B2%D0%B0%D1%8F_%D0%BC%D0%BE%D0%B4%D0%B5%D0%BB%D1%8C)#HSV_%E2%86%92_RGB
function HSV2RGB(h, s, v)
  if 0 == a:s
    return [
	  \ float2nr(ceil(a:v * 2.55)),
	  \ float2nr(ceil(a:v * 2.55)),
	  \ float2nr(ceil(a:v * 2.55))
	  \ ]
  endif
  let l:vmin = ((100 - a:s) * a:v) / 100.0
  let l:a = (a:v - l:vmin) * (a:h%60) / 60.0
  let l:vinc = l:vmin + l:a
  let l:vdec = a:v - l:a
  let l:idx = a:h / 60
  if 0 == l:idx
    let l:rr = a:v
    let l:gg = l:vinc
    let l:vb = l:vmin
  elseif 1 == l:idx
    let l:rr = l:vdec
    let l:gg = a:v
    let l:vb = l:vmin
  elseif 2 == l:idx
    let l:rr = l:vmin
    let l:gg = a:v
    let l:vb = l:vinc
  elseif 3 == l:idx
    let l:rr = l:vmin
    let l:gg = l:vdec
    let l:vb = a:v
  elseif 4 == l:idx
    let l:rr = l:vinc
    let l:gg = l:vmin
    let l:vb = a:v
  else
    let l:rr = a:v
    let l:gg = l:vmin
    let l:vb = l:vdec
  endif
  return [
	\ float2nr(ceil(l:rr * 2.55)),
	\ float2nr(ceil(l:gg * 2.55)),
	\ float2nr(ceil(l:vb * 2.55))
	\ ]
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file HSV2RGB.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
