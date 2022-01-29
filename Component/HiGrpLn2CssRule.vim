" HiGrpLn2CssRule.vim		vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorer@mail2k.ru>
" Last change:	23 Jan 2022
" Version:	1.6.0
" Description:	преобразует заданную группу подсветки в указанной строке в
"		правило CSS
"		converting a given highlight group in a specified line to a CSS
"		rule
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



function s:HiGrpLn2CssRule(grpname, grplnr)
  if !empty(a:grpname) && (a:grplnr || s:is_norm)
    let l:cssrule = []
    let l:comgrp = a:grpname
    let l:fndlnr = a:grplnr
" На тот случай, если не определена группа "Normal", а в первой строке группа,
" которая ссылается на что‐то. Это вряд ли может быть, но лучше подстраховаться.
    if a:grplnr
      call setpos('.', [0, l:fndlnr, 1, 0])
" Для ситуаций, когда группа ссылается на ещё не обработанную группу, а также
" когда группа ссылается на не существующую группу.
      while (search('links to ', 'cW', l:fndlnr) == l:fndlnr)
" Переменная «l:n» и последующая проверка добавлены для обработки ошибок в
" цветовых схемах, когда группа ссылается сама на себя (встретилось в цветовй
" схеме «kellys»).
	let l:n = (matchlist(getline(l:fndlnr), '\%(links to \)\(\w\+\)'))[1]
	if l:comgrp ==? l:n
	  normal h
	  normal d$
	  break
	endif
	call setpos('.', [0, 1, 1, 0])
	let l:nfndlnr = search('^\<' ..l:n.. '\>', 'cW', line('$'))
	if !l:nfndlnr
	  execute l:fndlnr 'delete'
	  return -1
	endif
	let l:comgrp = l:n
	let l:fndlnr = l:nfndlnr
      endwhile
    endif
    let l:csssel = s:HiGrpNm2CssSel(l:comgrp)
    if !empty(l:csssel) && type(0) != type(l:csssel)
      if a:grplnr
" Номер строки, в которой находится группа, мог изменится при удалении связаных
" групп
	call setpos('.', [0, 1, 1, 0])
	let l:fndlnr = search('^\<' ..l:comgrp.. '\>', 'cW', line('$'))
      endif
      let l:hiattr = s:ParseHiArgs(l:fndlnr)
      if !empty(l:hiattr) && type(0) != type(l:hiattr)
	let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
	if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
	  call insert(l:cssrule, l:csssel)
	  let l:cssrule += l:cssdecl
	endif
      endif
    endif
" Всё одно удаляем строку с этой группой, даже если не смогли распознать атрибуты
    call deletebufline(s:NME_TMP_BUF, l:fndlnr)
    return l:cssrule
  endif
  return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file HiGrpLn2CssRule.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
