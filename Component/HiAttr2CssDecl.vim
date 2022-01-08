" HiAttr2CssDecl.vim		vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.4.9
" Description:	преобразует распознанные значения атрибутов команды `highlight`
"		в декларации CSS
"		converts recognized attribute values of the command `highlight'
"		into CSS declarations
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



" Общие значения
let s:bg_norm = ''
let s:fg_norm = ''


function s:HiAttr2CssDecl(hiattrval)
  if !empty(a:hiattrval)
    let l:cssdecl = []
    let l:fnt = {}
    if has_key(a:hiattrval, 'font')
      let l:fnt = a:hiattrval['font']
    endif
    if !empty(l:fnt)
" Формируем объявление (декларацию) для шрифта
      if has_key(l:fnt, 'fntname')
	call add(l:cssdecl, 'font-family: "'..l:fnt['fntname']..'", monospace;')
      endif
      if has_key(l:fnt, 'fnthght')
" Для X11 делим на десять. Едининцы измерения устаналвиаем в пункты (points),
" как указано для шрифта в справке Vim
	if has('gui_win32') || has('gui_gtk2') || has('gui_gtk3') || has('gui_mac')
	  call add(l:cssdecl, 'font-size: '..l:fnt['fnthght']..'pt;')
	elseif has('X11')
	  call add(l:cssdecl, 'font-size: '..(l:fnt['fnthght']/10)..'pt;')
	endif
      endif
      if has_key(l:fnt, 'fntwdt')
" НАДО: составить какую‐то таблицу соответсвий для свойств, определённых для X11
" и ключевых слов, определённых в CSS. Не все свойства X11 совпадают с CSS
" НАДО: посмотреть, как Windows высчитывает ширину символов и как это
" соотносится с CSS
	if has('X11')
	  call add(l:cssdecl, 'font-stretch: '..(tr(l:fnt['fntwdt'], ' ', '-'))..';')
	endif
      endif
      if has_key(l:fnt, 'fntwght')
" Старые «Иа» не очень поддерживали числовые значения для насыщенности (жирности)
" шрифтов, но, всё же, оставим это
	call add(l:cssdecl, 'font-weight: '..l:fnt['fntwght']..';')
      endif
      if get(l:fnt, 'fntbold')
" На всякий случай. Пересекаться не должны, но...
	let l:idx = match(l:cssdecl, 'font-weight')
	if 0 <= l:idx
	  let l:cssdecl[l:idx] = 'font-weight: bold;'
	else
	  call add(l:cssdecl, 'font-weight: bold;')
	endif
      endif
      if get(l:fnt, 'fntitlc')
	call add(l:cssdecl, 'font-style: italic;')
      endif
" Обрабатываем ситуацию, когда для группы «Normal» не получен шрифт, или вообще
" отсутствует определнеие этой группы в цветовой схеме
    elseif s:is_norm
      call add(l:cssdecl, 'font-family: monospace;')
    endif

    if get(a:hiattrval, 'wght')
" Хотя... если в Windows задать это свойство обеими способами, то возвращает
" только одно из них
      let l:idx = match(l:cssdecl, 'font-weight')
      if 0 <= l:idx
	if 0 > match(l:cssdecl[l:idx], 'bold')
	  let l:cssdecl[l:idx] = 'font-weight: bold;'
	endif
      else
	call add(l:cssdecl, 'font-weight: bold;')
      endif
    endif

    if get(a:hiattrval, 'itlc')
" Аналогично предыдущему с насыщенностью, но лучше пока оставим. Черевато
" потерей производительности
      let l:idx = match(l:cssdecl, 'font-style:')
      if 0 <= l:idx
	if 0 > match(l:cssdecl[l:idx], 'italic')
	  let l:cssdecl[l:idx] = 'font-style: italic;'
	endif
      else
	call add(l:cssdecl, 'font-style: italic;')
      endif
    endif

" Формируем объявление (декларацию) для цвета заднего и переднего плана
    if has_key(a:hiattrval, 'bgco')
      let l:bgc = get(a:hiattrval, 'bgco')
      if 'NONE' ==? l:bgc && !s:is_norm
	call add(l:cssdecl, 'background-color: transparent;')
      elseif 'bg' ==? l:bgc && !s:is_norm
	if '' != s:bg_norm
	  call add(l:cssdecl, 'background-color: '..s:bg_norm..';')
	else
	  return -1
	endif
      elseif 'fg' ==? l:bgc && !s:is_norm
	if '' != s:fg_norm
	  call add(l:cssdecl, 'background-color: '..s:fg_norm..';')
	else
	  return -1
	endif
      else
	call add(l:cssdecl, 'background-color: '..l:bgc..';')
" Это как‐то неуклюже получилось, но что‐то другое в одну строку не придумал
	let s:bg_norm = s:is_norm ? l:bgc : s:bg_norm
"	let s:bg_norm = s:bg_norm ?? l:bgc
      endif
" На случай, если для группы «Normal» не определены эти значения
    elseif s:is_norm
      call add(l:cssdecl, 'background-color: transparent;')
" НАДО: посмотреть, как в Vim это реализовано. Прикинуть, как вытаскивать
" системные значения. Для Windows я примерно представляю, а вот в других не очень
      let s:bg_norm = '#FFFFFF'
    endif

    if has_key(a:hiattrval, 'fgco')
" Чтобы каждый раз не дёргать эту функцию
      let l:fgc = get(a:hiattrval, 'fgco')
      if 'NONE' ==? l:fgc && !s:is_norm
	call add(l:cssdecl, 'color: inherit;')
      elseif 'bg' ==? l:fgc && !s:is_norm
	if '' != s:bg_norm
	  call add(l:cssdecl, 'color: '..s:bg_norm..';')
	else
	  return -1
	endif
      elseif 'fg' ==? l:fgc && !s:is_norm
	if '' != s:fg_norm
	  call add(l:cssdecl, 'color: '..s:fg_norm..';')
	else
	  return -1
	endif
      else
	call add(l:cssdecl, 'color: '..l:fgc..';')
" Это как‐то неуклюже получилось, но что‐то другое в одну строку не придумал
	let s:fg_norm = s:is_norm ? l:fgc : s:fg_norm
      endif
" На случай, если для группы «Normal» не определены эти значения
    elseif s:is_norm
      call add(l:cssdecl, 'color: inherit;')
" НАДО: посмотреть, как в Vim это реализовано. Прикинуть, как вытаскивать
" системные значения. Для Windows я примерно представляю, а вот в других не очень
      let s:fg_norm = '#000000'
    endif

    if !empty(l:fnt)
      if get(l:fnt, 'fntundr')
	call add(l:cssdecl, 'text-decoration: underline;')
      endif
      if get(l:fnt, 'fntsout')
	let l:idx = match(l:cssdecl, 'text-decoration')
	if 0 <= l:idx
	  let l:cssdecl[l:idx] = trim(l:cssdecl[l:idx], ';', 2)..' line-throught;'
	else
	  call add(l:cssdecl, 'text-decoration: line-throught;')
	endif
      endif
    endif

    if get(a:hiattrval, 'undlne') && !s:is_norm
" Тоже, что и рашьше. В Windows, как правило, только одно свойство возвращается
      let l:idx = match(l:cssdecl, 'text-decoration')
      if 0 <= l:idx
	if 0 > match(l:cssdecl[l:idx], 'underline')
	  let l:cssdecl[l:idx] = trim(l:cssdecl[l:idx], ';', 2)..' underline;'
	endif
      else
	call add(l:cssdecl, 'text-decoration: underline;')
      endif
    endif

    if get(a:hiattrval, 'skthro') && !s:is_norm
" Аналогично
      let l:idx = match(l:cssdecl, 'text-decoration')
      if 0 <= l:idx
	if 0 > match(l:cssdecl[l:idx], 'line-throught')
	  let l:cssdecl[l:idx] = trim(l:cssdecl[l:idx], ';', 2)..' line-throught;'
	endif
      else
	call add(l:cssdecl, 'text-decoration: line-throught;')
      endif
    endif

    if get(a:hiattrval, 'undcrl') && !s:is_norm
" Эта декларация старыми «осликами» и проч. не поддерживается, как я помню.
" Поэтому первой записью будет просто text-decoration
      call add(l:cssdecl,
	  \ 'text-decoration: underline;'
	  \ .. ' -moz-text-decoration-line: underline; -moz-text-decoration-style: wavy;'
	  \ .. ' -webkit-text-decoration-line: underline; -webkit-text-decoration-style: wavy;'
	  \ .. ' text-decoration-line: underline; text-decoration-style: wavy;')
    endif

    if has_key(a:hiattrval, 'spco') && !s:is_norm
      let l:tdc = get(a:hiattrval, 'spco')
" Тоже и с этим объявлением и поддержикой ранними обозревателями страниц Интернета
      if 'NONE' ==? l:tdc
	call add(l:cssdecl, '-moz-text-decoration-color: currentColor;'
	    \ .. ' -webkit-text-decoration-color: currentColor;'
	    \ .. ' text-decoration-color: currentColor;')
      elseif 'bg' ==? l:tdc
	if '' != s:bg_norm
	  call add(l:cssdecl,
	      \ '-moz-text-decoration-color: '..s:bg_norm..';'
	      \ .. ' -webkit-text-decoration-color: '..s:bg_norm..';'
	      \ .. ' text-decoration-color: '..s:bg_norm..';')
	else
	  return -1
	endif
      elseif 'fg' ==? l:tdc
	if '' != s:fg_norm
	  call add(l:cssdecl,
	      \ '-moz-text-decoration-color: '..s:fg_norm..';'
	      \ .. ' -webkit-text-decoration-color: '..s:fg_norm..';'
	      \ .. ' text-decoration-color: '..s:fg_norm..';')
	else
	  return -1
	endif
      else
	call add(l:cssdecl, '-moz-text-decoration-color: '..l:tdc..';'
	    \ .. ' -webkit-text-decoration-color: '..l:tdc..';'
	    \ .. ' text-decoration-color: '..l:tdc..';')
      endif
    endif

    if get(a:hiattrval, 'rvrs') && !s:is_norm
      if '' != s:fg_norm && '' != s:bg_norm
	let @i = -1
	let @f = ''
	let @x = -1
	let @b = ''
	let l:idx = match(l:cssdecl, '\<color')
	if 0 <= l:idx
" Если цвет переднего плана определён ранее, то сохраняем его индекс объялвения
" и значение
	  let @i = l:idx
	  let @f = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	endif
	let l:idx = match(l:cssdecl, 'background-color')
	if 0 <= l:idx
" И для цвета заднего плана
	  let @x = l:idx
	  let @b = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	endif
	if -1 != @i && -1 != @x
" Если и то, и то задано, то тупо меняем их местами
	  let l:cssdecl[@i] = 'color: ' .. @b .. ';'
	  let l:cssdecl[@x] = 'background-color: ' .. @f .. ';'
	elseif -1 != @i && -1 == @x
" Задан только цвет переднего плана. Присвоим ему значение цвета общего заднего
" плана, а цвет заднего плана для элемента — заданное значние
	  let l:cssdecl[@i] = 'color: ' .. s:bg_norm .. ';'
	  call add(l:cssdecl, 'background-color: ' .. @f .. ';')
	elseif -1 == @i && -1 != @x
" Здесь же наоборот, присвоено значение только для заднего плана
	  call add(l:cssdecl, 'color: ' .. @b .. ';')
	  let l:cssdecl[@x] = 'background-color: ' .. s:fg_norm .. ';'
	elseif -1 == @i && -1 == @x
" Есть реверс, но нет заданных значений. Используем общее значение
	  call add(l:cssdecl, 'color: ' .. s:bg_norm .. ';')
	  call add(l:cssdecl, 'background-color: ' .. s:fg_norm .. ';')
	endif
      else
	return -1
      endif
    endif

    if get(a:hiattrval, 'rset') && !s:is_norm
" Сбросим всё к чертям, даже если и не задано
      let l:idx = match(l:cssdecl, 'font-weight')
      if 0 <= l:idx
	let l:cssdecl[l:idx] = 'font-weight: normal;'
      else
	call add(l:cssdecl, 'font-weight: normal;')
      endif
      let l:idx = match(l:cssdecl, 'font-style')
      if 0 <= l:idx
	let l:cssdecl[l:idx] = 'font-style: normal;'
      else
	call add(l:cssdecl, 'font-style: normal;')
      endif
      let l:idx = match(l:cssdecl, 'text-decoration')
      if 0 <= l:idx
	let l:cssdecl[l:idx] = 'text-decoration: none;'
      else
	call add(l:cssdecl, 'text-decoration: none;')
      endif
      let l:idx = match(l:cssdecl, 'text-decoration-color')
      if 0 <= l:idx
	let l:cssdecl[l:idx] =
		    \ '-moz-text-decoration-color: currentColor;'
		    \ .. ' -webkit-text-decoration-color: currentColor;'
		    \ .. ' text-decoration-color: currentColor;'
      endif
    endif

    if get(a:hiattrval, 'lum')
" https://cmd.inp.nsk.su/old/cmd2/manuals/gnudocs/gnudocs/termcap/termcap_33.html
" https://www.linuxlib.ru/manpages/TERMINFO.4.shtml#12
" Если я правильно понял, то 'standout' это, в данном контексте, «высвечивание»
" Что ж, попробуем. Для этого уменьшим яркость цвета заднего плана и увеличим
" яркость цвета переднего плана
      if '' != s:fg_norm && '' != s:bg_norm
	let @i = -1
	let @f = ''
	let @x = -1
	let @b = ''
	let l:idx = match(l:cssdecl, '\<color')
	if 0 <= l:idx
" Если цвет переднего плана определён, то сохраняем индекс объялвения и значение
	  let @i = l:idx
	  let @f = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	else
	  let @f = s:fg_norm
	endif
	let l:idx = match(l:cssdecl, 'background-color')
	if 0 <= l:idx
" И для цвета заднего плана
	  let @x = l:idx
	  let @b = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	else
" Если нет определения, используем значения «Normal»
	  let @b = s:bg_norm
	endif
	if ('#FFFFFF' !=? @f) || ('#000000' !=? @b)
	  let @f = s:BrightColo(@f, 20, 'l')
	  let @b = s:BrightColo(@b, 10, 'd')
	else
" Так как почти невозможно сделать белый цвет ярче, а чёрный темнее, то меняеме
" местами цвет переднего плана и цвет заднего плана. Т. е. такой вот реверс
	  let @F = @b
	  let @b = substitute(@f, '\c' .. @b, '', '')
	  let @f = substitute(@f, '\c' .. @b, '', '')
	endif
	if 0 <= @i
	  let l:cssdecl[@i] = 'color: ' .. @f .. ';'
	else
	  call add(l:cssdecl, 'color: ' .. @f .. ';')
	endif
	if 0 <= @x
	  let l:cssdecl[@x] = 'background-color: ' .. @b .. ';'
	else
	  call add(l:cssdecl, 'background-color: ' .. @b .. ';')
	endif
      else
	return -1
      endif
    endif

    if get(a:hiattrval, 'ncomb')
" что‐то делаем
    endif
    let l:cssdecl[0] = '{' .. l:cssdecl[0]
    let l:cssdecl[-1] = l:cssdecl[-1] .. '}'
    return l:cssdecl
  endif
    return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file HiAttr2CssDecl.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
