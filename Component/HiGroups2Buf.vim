" HiGroups2Buf.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.3.7
" Description:	выводит в новый буфер все действующие в данный момент группы
"		подсветки
"		outputs all currently active highlight groups to a new buffer
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/




" Общие переменные
let s:NME_TMP_BUF = 'Tmp_Colo2CSS'
lockvar s:NME_TMP_BUF

" Честно подсмотрено в hitest.vim
function s:HiGroups2Buf()
" сохраняем действующие значения параметров
"  let s:hidden_old      = &hidden
"  let s:lazyredraw_old  = &lazyredraw
"  let s:more_old        = &more
"  let s:report_old      = &report
"  let s:whichwrap_old   = &whichwrap
"  let s:shortmess_old   = &shortmess
"  let s:wrapscan_old    = &wrapscan
"  let s:spell_old       = &spell
"  let s:whichwprap_old  = &whichwrap
"  let s:register_a_old  = @h
"  let s:register_se_old = @/

" задаём необходимые нам значения параметров
  set hidden lazyredraw nomore noshowcmd noruler nospell nowrapscan
  set whichwrap& verbose=0 report=99999 shortmess=aAoOsStTWIcF

" Считываем в регистр "h вывод команды `highlight`
  redir @h
  silent highlight
  redir END

" Создаём новое окно если текущее окно содержит какой‐нибудь текст
" НАДО: в окончательном варианте это удалить, т. к. не потребуется и
" сделано здесь для целей тестирования
 if line("$") != 1 || getline(1) != ""
   new
 endif

" Создаём временный буфер
  execute 'edit ' .. s:NME_TMP_BUF

" И устанавливаем для него необходимые локальные параметры
  setlocal textwidth=0
  setlocal noautoindent noexpandtab formatoptions=""
  setlocal noswapfile nowrap wrapmargin=0
  setlocal buftype=nofile

" Помещаем в созданный буфер содержимое регистра "h
  put h

" Удалим те группы, которые не заданы в этой цветовой схеме
  silent! global/ cleared$/delete

" Также удаляем символы «xxx» в выводе команды `:highlight`
" global/xxx /s///e
  %substitute/xxx //e

" Объединяем строки, если есть перенос при маленьком размере окна и длинной
" строке
"  silent! global/^\s*links to \w\+/.-1join
  silent! global/^\s\+\w\+/.-1join

" Для ускорения поиска удаляем пустые строки
  silent! global/^\s*$/delete

" Зачистим журнал, чтобы следов не оставлять
  call histdel("search", -1)

"Обрабатывать будем только группы и аттрибуты для gui, прочие удалим, чтобы не
"мешались под рукой
" global/\%[c]term=\w\+,\=\%[\w]\+\s/s///eg
" global/\%[c]term\%(bg\|fg\|ul\)=\w\+\s/s///eg
"
" silent! global/\%[c]term=\w\+\s/s///eg

" silent! global/cterm=\w\+\s/s///eg
" silent! %substitute/\<cterm=\%(\w\+\s//e
" silent! global/cterm=\w\+,\w\+\s/s///eg
" silent! %substitute/\<cterm=\w\+,\w\+\s//e
" silent! global/term=\w\+\s/s///eg
" silent! %substitute/\<term=\w\+\s//e

" silent! global/\%[c]term=\w\+,\w\+\s/s///eg

" silent! global/term=\w\+,\w\+\s/s///eg
" silent! %substitute/\<term=\w\+,\w\+\s//e
" silent! global/start=\w\+\s/s///e
" silent! %substitute/\<start=\w\+\s//e
" silent! global/stop=\w\+\s/s///e
" silent! %substitute/\<stop=\w\+\s//e
" silent! global/ctermfg=\w\+\s/s///e
" silent! %substitute/\<ctermfg=\w\+\s//e
" silent! global/ctermbg=\w\+\s/s///e
" silent! %substitute/\<ctermbg=\w\+\s//e
" silent! global/ctermul=\w\+\s/s///e
" silent! %substitute/\<ctermul=\w\+\s//e
endfunction

" call s:HiGroups2Buf()


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file HiGroups2Buf.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
