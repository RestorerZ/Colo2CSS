" GetLnkGrp.vim		vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:   Restorer, <restorer@mail2k.ru>
" Last change:	29 Jan 2022
" Version:	1.1.6
" Description:	возвращает перечень наименований групп подсветки, которые
"		ссылаются на указанную группу
"		returns a list of the names of the highlight groups that link to
"		the specified group
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



function s:GetLnkGrp(grpname)
  if !empty(a:grpname)
    if !cursor(1,1)
      let l:lnkgrpnm = ''
      let l:lnr = 1
      while l:lnr
	let l:fndlnr =
	      \ search('links to\s\+' .. a:grpname .. '$', 'cnW', line('$'))
	if l:fndlnr
	  let l:lnkgrpnm = s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
	  if !empty(l:lnkgrpnm)
	    let @L = ' '..l:lnkgrpnm
	  endif
	  execute l:fndlnr 'delete'
" Могут быть группы, которые ссылаются на эту группу, которая ссылается на
" на начальную группу
	  call s:GetLnkGrp(l:lnkgrpnm)
	endif
	let l:lnr = l:fndlnr
      endwhile
      return @L
    endif
  endif
  return -1
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file GetLnkGrp.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
