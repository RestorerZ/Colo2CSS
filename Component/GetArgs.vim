" GetArgs.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.7.19
" Description:	
"		
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





" Аргументы команды:
" :TOcss [[ALL | list_files] [dark | light] [outdir]]
" где
" аргумент ALL ‐ все файлы цветовых схем, находящиеся в каталогах заданных в
" параметрах 'runtimepath', 'packpath'
" аргумет list_files ‐ перечень файлов цветовых схем, которые требуется
" преобразовать в файлы CSS. Если указано более одного файла, то файлы
" разделяются символом запятой без пробелов. В наименовании файлов не
" допускаются запятые.
" аргументы dark или light ‐ фон, применяемый для цветовых схем при их загрузке
" в редактор Vim для последующей конвертации.
" аргумент outdir ‐ каталог для готовых файлов CSS. Задаётся как абсолютный
" маршрут. Каталог должен существовать и быть доступен для записи в него файлов.




function <SID>GetArgs(...)
  let l:inargs = a:000[0]
  let l:outargs = [[], '', '', '']
" Проверяем какие аргументы передали и соответствуют ли они требуемым
  for l:arg in l:inargs
    if 'dark' ==# l:arg || 'light' ==# l:arg
      let l:outargs[1] = l:arg
    continue
    endif
    if l:arg->isdirectory()
      let l:outargs[2] = l:arg
    continue
    endif
    if 0 == index(l:inargs, l:arg)
      if 'ALL' ==# l:arg
" Подсмотренно в файле «menu.vim»
	let l:outargs[0] += globpath(&runtimepath, 'colors/*.vim', 1, 1)
	let l:outargs[0] += globpath(&packpath, 'pack/*/start/*/colors/*.vim', 1, 1)
	let l:outargs[0] += globpath(&packpath, 'pack/*/opt/*/colors/*.vim', 1, 1)
      continue
      endif
      let l:lstfls = split(l:arg, ',')
      for l:clfl in l:lstfls
	if 'vim' ==? l:clfl->fnamemodify(':e')
	  let l:outargs[0] += globpath(&runtimepath, 'colors/'..l:clfl, 1, 1)
	  let l:outargs[0] += globpath(&packpath, 'pack/*/start/*/colors/'..l:clfl, 1, 1)
	  let l:outargs[0] += globpath(&packpath, 'pack/*/opt/*/colors/'..l:clfl, 1, 1)
	else
	  let l:outargs[0] += globpath(&runtimepath, 'colors/'..l:clfl..'.vim', 1, 1)
	  let l:outargs[0] += globpath(&packpath, 'pack/*/start/*/colors/'..l:clfl..'.vim', 1, 1)
	  let l:outargs[0] += globpath(&packpath, 'pack/*/opt/*/colors/'..l:clfl..'.vim', 1, 1)
	endif
      endfor
    endif
  endfor
" При необходимости дополняем отсутствующие аргументы и приводим к требуемому виду 
  if empty(l:outargs[0])
    let l:outargs[0] = ['']
  else
" Для команды ":colorscheme" нажны только наименования без расположения и
" расширения файла. Также в списке могут быть дубли, если файлы расположены в
" нескольких каталогах. С функцией uniq() что‐то у меня не задалось. Сделал так.
    call map(l:outargs[0], 'fnamemodify(v:val, ":t:r")')
    call filter(l:outargs[0], '1 == count(l:outargs[0], v:val, v:true)')
    if empty(l:outargs[3])
"      silent runtime autoload/colo2css.vim
      let l:outargs[3] = colo2css#GetInitFont()
    endif
  endif
  if empty(l:outargs[2])
" Нужен католог, куда разрешено писать пользователю
    let l:wrtdir = getenv('HOME')
    if v:null == l:wrtdir
      let l:wrtdir = (getenv('MYVIMRC')->fnamemodify(':p:h'))
    endif
    if !isdirectory(l:wrtdir .. '/Colo2CSS')
      if exists('*mkdir') && (mkdir(l:wrtdir .. '/Colo2CSS', '', '0o755'))
	let l:outargs[2] = l:wrtdir .. '/Colo2CSS'
      else
	let l:wrtdir = getenv('TEMP')
	let l:outargs[2] = l:wrtdir
      endif
    else
      let l:outargs[2] = l:wrtdir .. '/Colo2CSS'
    endif
  endif
  return l:outargs
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file GetArgs.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
