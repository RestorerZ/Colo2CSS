" GetEntry.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.0.1
" Description:	возвращает скопированный текст из указанной части буфера
"		returns the copied part of the buffer text from the specified
"		position
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/




function s:GetEntry(bnr, lnr, cnr, offset, motion)
  let @e = ''
  if !setpos('.', [a:bnr, a:lnr, a:cnr, a:offset])
    execute 'normal "ey' .. a:motion
  endif
  return getreg('e')
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file GetEntry.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
