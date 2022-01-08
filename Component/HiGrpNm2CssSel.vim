" HiGrpNme2CssSel.vim		vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.4.2
" Description:	преобразует наименование заданной группы и наименования всех
"		связанных с ней групп подсветки в селекторы CSS
"		converts the name of a given group and the names of all linked
"		highlight groups into CSS selectors
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



function s:HiGrpNme2CssSel(grpname)
  if !empty(a:grpname)
    let l:csssel = ''
" Т. к. функция GetLnkGrp работает с регистром "l, то предварительно
" подгатавливаем его.
    let @l = ''
    let l:csssel = s:GetLnkGrp(a:grpname)
    if empty(l:csssel)
      let l:csssel = s:is_norm ? '*, .'..a:grpname : '.'..a:grpname
    elseif type(0) != type(l:csssel)
" Расставляем запяты и точки в полученном перечне связанных групп
      let l:csssel = substitute(l:csssel, '\%(\s\)\(\w\+\)', ', .\1', 'g')
      let l:csssel =
		  \ s:is_norm ? '*, .'..a:grpname..
		  \ l:csssel :
		  \ '.'..a:grpname..
		  \ l:csssel
    endif
    return l:csssel
  endif
  return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file HiGrpNme2CssSel.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
