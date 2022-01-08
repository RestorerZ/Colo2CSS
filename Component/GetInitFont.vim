" GetInitFont.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.1.2
" Description:	возвращает заданное значение шрифта используемого в программе Vim
"		returns the specified value of the font used in the program Vim
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





function GetInitFont()
  let @t = ''
  let @t = getfontname()
  if empty(@t)
    if !has('X11')
      let @t = &guifont
    else
      let @t = &guifontset
    endif
    if !empty(@t)
" Шаблон поиска не очень изящный
      let l:com = match(@t, '\w,')
      if 0 < l:com
	  let @t = strpart(@t, 0, l:com)
      endif
    endif
  endif
  return getreg('t')
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file GetInitFont.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
