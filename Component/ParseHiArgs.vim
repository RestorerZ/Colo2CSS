" ParseHiArgs.vim		vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	24 Jan 2022
" Version:	1.9.0
" Description:	разбор значений аргументов и атрибутов групп подсветки
"		parsing the values of arguments and attributes of highlighting
"		groups
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/




const s:HI_ARGS = ['gui', 'guifg', 'guibg', 'guisp', 'font']


const s:SPEC_ATTR = [['bold', 'wght'], ['italic', 'itlc'],
  \ ['underline', 'undlne'], ['undercurl', 'undcrl'],
  \ ['reverse', 'rvrs'], ['inverse', 'rvrs'],
  \ ['strikethrough', 'skthro'], ['NONE', 'rset'],
  \ ['standout', 'lum'], ['nocombine', 'ncomb']]



function s:ParseHiArgs(grplnr)
  if !empty(a:grplnr)
    let l:hiattr = {}
    let l:str = getline(a:grplnr)
    for l:hiarg in s:HI_ARGS
      let @s = ''
      let l:pos = matchend(l:str, l:hiarg .. '=')
      if 0 <= l:pos
	if 'gui' == l:hiarg
	  let @s = s:GetEntry(0, a:grplnr, l:pos+1, 0, 'E')
	  let l:idx = 0
	  while !empty(@s) && l:idx < len(s:SPEC_ATTR)
	    if 0 <= (stridx(@s, s:SPEC_ATTR[l:idx][0]))
	      let l:hiattr[s:SPEC_ATTR[l:idx][1]] = 1
	      let @s =
		\ substitute(@s, s:SPEC_ATTR[l:idx][0]..'\%(,\|\s\)\=', '', '')
	    endif
	    let l:idx += 1
	  endwhile
	elseif 'guifg' == l:hiarg || 'guibg' == l:hiarg || 'guisp' == l:hiarg
	  let l:pos2 = match(l:str, '\%( gui\| font\|$\)', l:pos)
	  if 0 < l:pos2
	    let @s = s:GetEntry(0, a:grplnr, l:pos+1, 0, (l:pos2-l:pos)..'l')
	    if !empty(@s)
	      let @s = s:GetColor(@s)
	      if !empty(@s) && -1 != (@s+0)
		if 'guifg' == l:hiarg
		  let l:hiattr['fgco'] = getreg('s')
		elseif 'guibg' == l:hiarg
		  let l:hiattr['bgco'] = getreg('s')
		elseif 'guisp' == l:hiarg
		  let l:hiattr['spco'] = getreg('s')
		endif
	      endif
	    endif
	  endif
	elseif 'font' == l:hiarg
	  let @s = s:GetEntry(0, a:grplnr, l:pos+1, 0, 'g_')
	  if !empty(@s)
	    let l:fnt = s:ParseFont(@s)
	    if !empty(l:fnt) && type(0) != type(l:fnt)
	      let l:hiattr['font'] = l:fnt
	    endif
	  endif
	endif
      elseif s:is_norm && 'font' == l:hiarg
	let @s = s:GetInitFont()
	if !empty(@s)
	  let l:fnt = s:ParseFont(@s)
	  if !empty(l:fnt) && type(0) != type(l:fnt)
	    let l:hiattr['font'] = l:fnt
	  endif
	endif
      endif
    endfor
    return l:hiattr
  elseif s:is_norm
    let l:hiattr = {'font':''}
    return l:hiattr
  else
    return -1
  endif
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file ParseHiArgs.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
