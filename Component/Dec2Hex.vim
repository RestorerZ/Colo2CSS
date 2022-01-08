" Dec2Hex.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.0.9
" Description:	преобразует десятичное число в шестнадцатеричное число
"		converts a decimal number to a hexadecimal number
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





function Dec2Hex(str)
" Так, конечно, делать не надо. Такие читы до добра не доводят!
" let l:hex=printf("%X", a:str)
" return l:hex
  let l:hexdig=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
  let l:hex=''
  let l:num=str2nr(a:str, 10)
  if !l:num
    return 0 .. l:num
  else
    while l:num
      let l:hex=l:hexdig[l:num%16] .. l:hex
      let l:num/=16
    endwhile
  endif
  if 255 < str2nr(l:hex, 16)
    return -1
  endif
  return ((2 > len(l:hex)) ? 0 .. l:hex : l:hex)
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file Dec2Hex.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
