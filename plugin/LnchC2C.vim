" LnchC2C.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	06 Jan 2022
" Version:	1.4.2
" Description:	вызов функций командного файла Colo2Css.vim с требуемыми параметрами
"		calling the functions of the Colo2Css.vim command file with the
"		required parameters	
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/




let s:old_set = &cpoptions
set cpo&vim
if has('user_commands') && !has(':TOcss')
  command! -nargs=* TOcss call <SID>Launch(<f-args>)
endif

function <SID>GetArgs(c2cfl, ...)
  let l:inargs = a:000[0]
  let l:outargs = [[], '', '', '']
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
  if empty(l:outargs[0])
    let l:outargs[0] = ['']
  else
    call map(l:outargs[0], 'fnamemodify(v:val, ":t:r")')
    call filter(l:outargs[0], '1 == count(l:outargs[0], v:val, v:true)')
    if empty(l:outargs[3])
      let l:outargs[3] = colo2css#GetInitFont()
    endif
  endif
  if empty(l:outargs[2])
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

function! <SID>Launch(...)
  let l:c2cfl = ''
  let l:pths = split(&runtimepath, ',')
  for l:pth in l:pths
    if filereadable(l:pth .. '/autoload/colo2css.vim')
      let l:c2cfl = l:pth .. '/autoload/colo2css.vim'
      break
    endif
  endfor
  if empty(l:c2cfl)
    exe 'normal \<Esc>'
    echoerr "Не удалось найти файл colo2css.vim. Дальнейшая работа модуля невозможна"
    echomsg "Для правильной работы подключаемого модуля файл colo2css.vim должен быть"
    echomsg "скопирован в подкаталог autoload одного из каталогов,"
    echomsg "указанных в значении параметра 'runtimepath'"
    return -1
  endif
  let l:args = <SID>GetArgs(l:c2cfl, a:000)
  if empty(l:args[0][0])
    silent runtime autoload/colo2css.vim
    call colo2css#MainColo2Css(l:args[0], l:args[1], l:args[2], l:args[3])
  else
    let l:cmdlns = ' -u NONE -U NONE -i NONE -N -n -S ' .. l:c2cfl 
    let l:cmdlnm = string(l:args[0])..', '..string(l:args[1])
	  \ ..', '..string(l:args[2])..', '..string(l:args[3])
    let l:cmdlne = ')"'
    if has('channel') && has('job')
      let l:cmdlns = l:cmdlns .. ' -c "call colo2css#MainColo2Css('
      if has('win32')
	let s:jb = job_start('gvim.exe' .. l:cmdlns .. l:cmdlnm .. l:cmdlne)
      elseif has('unix')
	let s:jb = job_start('vim -g' .. l:cmdlns .. l:cmdlnm .. l:cmdlne])
      endif
    else
      let l:cmdlns = l:cmdlns .. ' -c "call colo2css\#MainColo2Css('
      if has('win32')
	silent execute('!start /min gvim.exe' .. l:cmdlns .. l:cmdlnm .. l:cmdlne)
      elseif has('unix')
	silent execute('!vim -g ' .. l:cmdlns .. l:cmdlnm .. l:cmdlne)
      endif
    endif
  endif
endfunction
let &cpo = s:old_set
unlet s:old_set


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file Lanuch.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
