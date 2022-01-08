" RGB2YUV.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.0.1
" Description:	конвертация значений цветовой модели RGB в значения модели YUV
"		converting RGB color model values to YUV model values
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





" https://ru.wikipedia.org/wiki/YUV
" http://forum.vingrad.ru/index.php?showtopic=192508&view=findpost&p=1402685
" https://softpixel.com/~cwright/programming/colorspace/yuv/
function RGB2YUV(hexcolo)
  let l:rr = str2nr(a:hexcolo[0:1], 16)
  let l:gg = str2nr(a:hexcolo[2:3], 16)
  let l:bb = str2nr(a:hexcolo[4:5], 16)
"  let l:Y = 0.299 * l:rr + 0.587 * l:gg + 0.114 * l:bb
"  let l:U = (l:bb - l:Y) / 2.03
"  let l:V = (l:rr - l:Y) / 1.44
  let l:Y = 0.299000 * l:rr + 0.587000 * l:gg + 0.114000 * l:bb
  let l:U = -0.168736 * l:rr + -0.331264 * l:gg + 0.500000 * l:bb + 128
  let l:V = 0.500000 * l:rr + -0.418688 * l:gg + -0.081312 * l:bb + 128
  return [l:Y, l:U, l:V]
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file RGB2YUV.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
