" YUV2RGB.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.0.1
" Description:	конвертация значений цветовой модели YUV в значения модели RGB
"		converting YUV color model values to RGB model values
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





" https://ru.wikipedia.org/wiki/YUV
" http://forum.vingrad.ru/index.php?showtopic=192508&view=findpost&p=1402685
" https://softpixel.com/~cwright/programming/colorspace/yuv/
function YUV2RGB(Y, U, V)
"  let l:rr = a:V * 1.44 + a:Y
"  let l:gg = a:Y - 0.37 - 0.73 * a:V
"  let l:bb = a:Y + 2.03 * a:U
  let l:rr = a:Y + 1.4075 * (a:V - 128)
  let l:gg = a:Y - 0.3455 * (a:U - 128) - (0.7169 * (a:V - 128))
  let l:bb = a:Y + 1.7790 * (a:U - 128)
"  let l:rr = 0 > l:rr ? 0 : 255 < l:rr ? 255 : l:rr
  let l:rr = 0 > float2nr(round(l:rr)) ? 0 :
	  \ 255 < float2nr(round(l:rr)) ? 255 : float2nr(round(l:rr))
"  let l:gg = 0 > l:gg ? 0 : 255 < l:gg ? 255 : l:gg
  let l:gg = 0 > float2nr(round(l:gg)) ? 0 :
	  \ 255 < float2nr(round(l:gg)) ? 255 : float2nr(round(l:gg))
"  let l:bb = 0 > l:bb ? 0 : 255 < l:bb ? 255 : l:bb
  let l:bb = 0 > float2nr(round(l:bb)) ? 0 :
	  \ 255 < float2nr(round(l:bb)) ? 255 : float2nr(round(l:bb))
  return [l:rr, l:gg, l:bb]
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file YUV2RGB.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.

