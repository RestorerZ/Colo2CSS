" Vimball Archiver by Charles E. Campbell
UseVimball
finish
autoload\colo2css.vim	[[[1
1027
" colo2css.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.8.12
" Description:	преобразование цветовой схемы Vim в файл CSS
"		converting a Vim color scheme to a CSS file
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





let s:old_set = &cpoptions
set cpo&vim

const s:NOT_RGB =
  \ [['darkyellow','8B8B00'],['lightmagenta','FF8BFF'],['lightred','FF8B8B']]

const s:WINSYS_COLO = {
  \ 'SYS_SCROLLBAR':['Scrollbar', 'COLOR_SCROLLBAR', 0],
  \ 'SYS_BACKGROUND':['Background', 'COLOR_BACKGROUND', 1],
  \ 'SYS_DESKTOP':['Background', 'COLOR_DESKTOP', 1],
  \ 'SYS_ACTIVECAPTION':['ActiveTitle', 'COLOR_ACTIVECAPTION', 2],
  \ 'SYS_INACTIVECAPTION':['InactiveTitle', 'COLOR_INACTIVECAPTION', 3],
  \ 'SYS_MENU':['Menu', 'COLOR_MENU', 4],
  \ 'SYS_WINDOW':['Window', 'COLOR_WINDOW', 5],
  \ 'SYS_WINDOWFRAME':['WindowFrame', 'COLOR_WINDOWFRAME', 6],
  \ 'SYS_MENUTEXT':['MenuText', 'COLOR_MENUTEXT', 7],
  \ 'SYS_WINDOWTEXT':['WindowText', 'COLOR_WINDOWTEXT', 8],
  \ 'SYS_CAPTIONTEXT':['TitleText', 'COLOR_CAPTIONTEXT', 9],
  \ 'SYS_ACTIVEBORDER':['ActiveBorder', 'COLOR_ACTIVEBORDER', 10],
  \ 'SYS_INACTIVEBORDER':['InactiveBorder', 'COLOR_INACTIVEBORDER', 11],
  \ 'SYS_APPWORKSPACE':['AppWorkspace', 'COLOR_APPWORKSPACE', 12],
  \ 'SYS_HIGHLIGHT':['Hilight', 'COLOR_HIGHLIGHT', 13],
  \ 'SYS_HIGHLIGHTTEXT':['HilightText', 'COLOR_HIGHLIGHTTEXT', 14],
  \ 'SYS_3DFACE':['ButtonFace', 'COLOR_3DFACE', 15],
  \ 'SYS_BTNFACE':['ButtonFace', 'COLOR_BTNFACE', 15],
  \ 'SYS_3DSHADOW':['ButtonShadow', 'COLOR_3DSHADOW', 16],
  \ 'SYS_BTNSHADOW':['ButtonShadow', 'COLOR_BTNSHADOW', 16],
  \ 'SYS_GRAYTEXT':['GrayText', 'COLOR_GRAYTEXT', 17],
  \ 'SYS_BTNTEXT':['ButtonText', 'COLOR_BTNTEXT', 18],
  \ 'SYS_INACTIVECAPTIONTEXT':['InactiveTitleText', 'COLOR_INACTIVECAPTIONTEXT', 19],
  \ 'SYS_3DHILIGHT':['ButtonHighlight', 'COLOR_3DHILIGHT', 20],
  \ 'SYS_3DHIGHLIGHT':['ButtonHighlight', 'COLOR_3DHIGHLIGHT', 20],
  \ 'SYS_BTNHILIGHT':['ButtonHighlight', 'COLOR_BTNHILIGHT', 20],
  \ 'SYS_BTNHIGHLIGHT':['ButtonHighlight', 'COLOR_BTNHIGHLIGHT', 20],
  \ 'SYS_3DDKSHADOW':['ButtonDkShadow', 'COLOR_3DDKSHADOW', 21],
  \ 'SYS_3DLIGHT':['ButtonLight', 'COLOR_3DLIGHT', 22],
  \ 'SYS_INFOTEXT':['InfoText', 'COLOR_INFOTEXT', 23],
  \ 'SYS_INFOBK':['InfoWindow', 'COLOR_INFOBK', 24]
  \ }

const s:FNT_SIZE = ['h', 'w', 'W']

const s:HI_ARGS = ['gui', 'guifg', 'guibg', 'guisp', 'font']

const s:SPEC_ATTR = [['bold', 'wght'], ['italic', 'itlc'],
  \ ['underline', 'undlne'], ['undercurl', 'undcrl'],
  \ ['reverse', 'rvrs'], ['inverse', 'rvrs'],
  \ ['strikethrough', 'skthro'], ['NONE', 'rset'],
  \ ['standout', 'lum'], ['nocombine', 'ncomb']]

const s:INIT_GRP = ['Normal', 'ColorColumn', 'Conceal', 'Cursor', 'CursorColumn',
  \ 'CursorIM', 'CursorLine', 'CursorLineNr', 'DiffAdd', 'DiffChange',
  \ 'DiffDelete', 'DiffText', 'Directory', 'EndOfBuffer', 'ErrorMsg',
  \ 'FoldColumn', 'Folded', 'IncSearch', 'LineNr', 'LineNrAbove',
  \ 'LineNrBelow', 'MatchParen', 'ModeMsg', 'MoreMsg', 'NonText', 'Pmenu',
  \ 'PmenuSbar', 'PmenuSel', 'PmenuThumb', 'Question', 'QuickFixLine',
  \ 'Search', 'SignColumn', 'SpecialKey', 'SpellBad', 'SpellCap',
  \ 'SpellLocal', 'SpellRare', 'StatusLine', 'StatusLineNC', 'StatusLineTerm',
  \ 'StatusLineTermNC', 'TabLine', 'TabLineFill', 'TabLineSel', 'Terminal',
  \ 'Title', 'VertSplit', 'Visual', 'VisualNOS', 'WarningMsg', 'WildMenu',
  \ 'lCursor']

let s:NME_TMP_BUF = 'Tmp_Colo2CSS'
lockvar s:NME_TMP_BUF
let s:is_norm = 0
let s:bg_norm = ''
let s:fg_norm = ''
let s:old_val = {}



function <SID>HiGroups2Buf()
  set hidden lazyredraw nomore noshowcmd noruler nospell nowrapscan
  set whichwrap& verbose=0 report=99999 shortmess=aAoOsStTWIcF
  redir @u
  silent highlight
  redir END
  execute 'edit ' .. s:NME_TMP_BUF
  setlocal textwidth=0
  setlocal noautoindent noexpandtab formatoptions=""
  setlocal noswapfile
  setlocal buftype=nofile
  put u
  silent! global/ cleared$/delete
  %substitute/xxx //e
  silent! global/^\s\+\w\+/.-1join
  silent! global/^\s*$/delete
  call histdel("search", -1)
endfunction

function <SID>GetEntry(bnr, lnr, cnr, offset, motion)
  let @e = ''
  if !setpos('.', [a:bnr, a:lnr, a:cnr, a:offset])
    execute 'normal "ey' .. a:motion
  endif
  return getreg('e')
endfunction

function <SID>Dec2Hex(str)
  let l:hexdig=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
  let l:hex=''
  let l:num=str2nr(a:str, 10)
  if !l:num
    return 0 .. l:num
  else
    while l:num
      let l:hex=l:hexdig[l:num%16] .. l:hex
      let l:num/=16
  endwhile
  endif
  if 255 < str2nr(l:hex, 16)
    return -1
  endif
  return ((2 > len(l:hex)) ? 0 .. l:hex : l:hex)
endfunction

function <SID>RGB2HSB(hexcolo)
  if !empty(a:hexcolo) && (6 == len(a:hexcolo))
    let l:rr = str2nr(a:hexcolo[0:1], 16)
    let l:gg = str2nr(a:hexcolo[2:3], 16)
    let l:bb = str2nr(a:hexcolo[4:5], 16)
    let l:max = max([l:rr, l:gg, l:bb])
    let l:min = min([l:rr, l:gg, l:bb])
    let l:rr /= 255.0
    let l:gg /= 255.0
    let l:bb /= 255.0
    let l:max /= 255.0
    let l:min /= 255.0
    let l:dlt = l:max - l:min
    if l:max != l:min
      if l:max == l:rr
	let l:h = (l:gg - l:bb) / l:dlt + (l:gg < l:bb ? 6 : 0)
      elseif l:max == l:gg
	let l:h = (l:bb - l:rr) / l:dlt + 2
      elseif l:max == l:bb
	let l:h = (l:rr - l:gg) / l:dlt + 4
      endif
	let l:h = float2nr(ceil(l:h * 60))
    else
      let l:h = 0
    endif
    if 0 == l:max
      let l:h = 0
      let l:s = 0
    else
      let l:s = float2nr((l:dlt / l:max) * 100)
    endif
    let l:b = float2nr(l:max * 100)
    return [l:h, l:s, l:b]
  else
    return -1
  endif
endfunction

function <SID>HSB2RGB(h, s, b)
  if ((360 >= a:h) && (0 <= a:h)) && ((100 >= a:s) && (0 <= a:s))
	\ && ((100 >= a:b) && (0 <= a:b))
    if 0 == a:s
      return [
	      \ float2nr(ceil(a:b * 2.55)),
	      \ float2nr(ceil(a:b * 2.55)),
	      \ float2nr(ceil(a:b * 2.55))
	      \ ]
    endif
    let l:max = a:b / 100.0
    let l:chrm = (a:s * a:b) / 10000.0
    let l:min = l:max - l:chrm
    if 300 <= a:h
      let l:hdrtv = (a:h - 360) / 60.0
    elseif 300 > a:h
      let l:hdrtv = a:h / 60.0
    endif
    let l:idx = float2nr(floor(l:hdrtv))
    if 0 == l:idx
      let l:rr = l:max
      let l:gg = l:min + l:hdrtv * l:chrm
      let l:bb = l:min
    elseif 1 == l:idx
      let l:rr = l:min - (l:hdrtv - 2) * l:chrm
      let l:gg = l:max
      let l:bb = l:min
    elseif 2 == l:idx
      let l:rr = l:min
      let l:gg = l:max
      let l:bb = l:min + (l:hdrtv - 2) * l:chrm
    elseif 3 == l:idx
      let l:rr = l:min
      let l:gg = l:min - (l:hdrtv - 4) * l:chrm
      let l:bb = l:max
    elseif 4 == l:idx
      let l:rr = l:min + (l:hdrtv - 4) * l:chrm
      let l:gg = l:min
      let l:bb = l:max
    else
      let l:rr = l:max
      let l:gg = l:min
      let l:bb = l:min - l:hdrtv * l:chrm
    endif
    return [
	    \ float2nr(ceil(l:rr * 255)),
	    \ float2nr(ceil(l:gg * 255)),
	    \ float2nr(ceil(l:bb * 255))
	    \ ]
  endif
  return -1
endfunction

function <SID>BrightColo(hexcolo, prcnt, lord)
  let l:hexcolo = ''
  let l:colo = trim(a:hexcolo, '#', 1)
  let l:prcnt = (100 < a:prcnt ? 100 : 0 > a:prcnt ? 0 : a:prcnt)
  let l:hsb = <SID>RGB2HSB(l:colo)
  if 'l' ==? a:lord
    if 99 <= l:hsb[2]
      let l:hsb[1] = l:hsb[1] - l:prcnt
    else
      let l:hsb[2] = l:hsb[2] + l:prcnt
    endif
  elseif 'd' ==? a:lord
    if 1 >= l:hsb[2]
      let l:hsb[1] += l:prcnt
    else
      let l:hsb[2] -= l:prcnt
    endif
  endif
  let l:hsb[1] = (100 < l:hsb[1] ? 100 : 0 > l:hsb[1] ? 0 : l:hsb[1])
  let l:hsb[2] = (100 < l:hsb[2] ? 100 : 0 > l:hsb[2] ? 0 : l:hsb[2])
  let l:rgb = <SID>HSB2RGB(l:hsb[0], l:hsb[1], l:hsb[2])
  let @u = ''
  for l:cc in l:rgb
    let @u = <SID>Dec2Hex(l:cc)
    if -1 == (@u+0)
      return -1
    endif
    let l:hexcolo = l:hexcolo .. @u
  endfor
  return '#' .. l:hexcolo
endfunction

function <SID>ColoStr2ColoNum(colostr)
  if !empty(a:colostr)
    for l:nrgb in s:NOT_RGB
      if a:colostr ==? l:nrgb[0]
	return l:nrgb[1]
      endif
    endfor
    if 8023562 <= v:versionlong && exists('v:colornames')
      if has_key(v:colornames, tolower(a:colostr))
	return toupper(v:colornames[tolower(a:colostr)][1:])
      endif
    endif
    let l:rgbcolo = ''
    if has('win32')
      if 0 <= stridx(toupper(a:colostr), 'SYS_', 0)
	let l:rgbcolo = system(
\ "powershell Get-ItemProperty -Path 'Registry::HKCU\\Control Panel\\Colors' -Name "
\ .. s:WINSYS_COLO[toupper(a:colostr)][0] .. " ^| Select-Object -ExpandProperty "
\ .. s:WINSYS_COLO[toupper(a:colostr)][0])
      elseif filereadable($VIMRUNTIME .. '/rgb.txt')
	let l:rgbcolo =
	  \ system("powershell Select-String -Path "
	  \ .. $VIMRUNTIME .. "\\rgb.txt -Pattern " .. "'\\t"
	  \ .. a:colostr .. "$'" .. " ^| "
	  \ .. "Select-Object -ExpandProperty Line")
      endif
    elseif has('unix')
      if filereadable($VIMRUNTIME .. '/rgb.txt')
	let l:rgbcolo =
	  \ system('grep -i -h -w -e "[[:space:]]' ..a:colostr.. '$" '
	  \ ..$VIMRUNTIME .. '/rgb.txt')
      endif
    endif
    if !empty(l:rgbcolo)
      let l:hexcolo = ''
      let l:rgbcolo = matchstr(l:rgbcolo, '\d\{1,3}\s\+\d\{1,3}\s\+\d\{1,3}')
      while !empty(l:rgbcolo)
	let @u = ''
	let @u = matchstr(l:rgbcolo, '^\d\{1,3}')
	let l:rgbcolo = substitute(l:rgbcolo, @u .. '\s*', '', '')
	let @u = <SID>Dec2Hex(@u)
	if -1 ==(@u+0)
	  return -1
	endif
	let l:hexcolo = l:hexcolo .. @u
      endwhile
      return l:hexcolo
    endif
  endif
  return -1
endfunction

function <SID>GetColor(coloval)
  if !empty(a:coloval)
    if '#' == a:coloval[0:0]
      return toupper(a:coloval)
    elseif 0 <= stridx(tolower(a:coloval), 'bg') ||
		    \ 0 <= stridx(tolower(a:coloval), 'background')
      return 'bg'
    elseif 0 <= stridx(tolower(a:coloval), 'fg') ||
		    \ 0 <= stridx(tolower(a:coloval), 'foreground')
      return 'fg'
    elseif 0 <= stridx(toupper(a:coloval), 'NONE')
      return 'NONE'
    elseif 0 <= match(a:coloval, '\w\+')
      let @u = ''
      let @u = <SID>ColoStr2ColoNum(a:coloval)
      if !empty(@u) && -1 != (@u+0)
	return '#' .. @u
      endif
    endif
  endif
  return -1
endfunction

function! colo2css#GetInitFont()
  let @u = ''
  let @u = getfontname()
  if empty(@u)
    if !has('X11')
      let @u = &guifont
    else
      let @u = &guifontset
    endif
    if !empty(@u)
      let l:cmm = match(@u, '\w,')
      if 0 < l:cmm
	let @u = strpart(@u, 0, l:cmm)
      endif
    endif
  endif
  return getreg('u')
endfunction

function <SID>ParseFont(fntval)
  if !empty(a:fntval)
    let l:fnt = {}
    if 'NONE' ==? a:fntval
      let l:hifnt = colo2css#GetInitFont()
    else
      let l:hifnt = a:fntval
    endif
    if has('gui_win32')
      let l:hifnt = substitute(l:hifnt, '\', '', 'g')
      let l:cln = stridx(l:hifnt, ':')
      if 0 < l:cln
	let l:fnt['fntname'] = tr(l:hifnt[0:l:cln-1], '_', ' ')
      elseif 0 > l:cln
	let l:fnt['fntname'] = tr(l:hifnt, '_', ' ')
      endif
      for l:fntsze in s:FNT_SIZE
	let l:sze =
	  \ matchlist(
	  \ l:hifnt, '\C\(:'..l:fntsze..'\)\(\d\{1,}\.\{,1}\d\{}\)')
	if !empty(l:sze)
	  if 'h' == l:fntsze
	    let l:fnt['fnthght'] = l:sze[2]
	    continue
	  elseif 'w' ==# l:fntsze
	    let l:fnt['fntwdth'] = l:sze[2]
	    continue
	  elseif 'W' ==# l:fntsze
	    let l:fnt['fntwght'] = l:sze[2]
	  endif
	endif
      endfor
      if 0 < stridx(l:hifnt, ':b')
	let l:fnt['fntbold'] = 1
      endif
      if 0 < stridx(l:hifnt, ':i')
	let l:fnt['fntitlc'] = 1
      endif
      if 0 < stridx(l:hifnt, ':u')
	let l:fnt['fntundr'] = 1
      endif
      if 0 < stridx(l:hifnt, ':s')
	let l:fnt['fntsout'] = 1
      endif
      return l:fnt
    elseif has('gui_gtk2') || has('gui_gtk3')
      let l:hifnt = substitute(l:hifnt, '\', '', 'g')
      let l:fnt['fntname'] = substitute(l:hifnt, '\s\+\d\+$', '', '')
      let l:fnt['fnthght'] = trim(matchstr(l:hifnt, '\s\d\+$'), ' ', 1)
      return l:fnt
    elseif has('X11')
      let l:hifnt = split(l:hifnt, '-')
      if !empty(l:hifnt[1]) && '*' != l:hifnt[1]
	let l:fnt['fntname'] = l:hifnt[1]
      endif
      if 'bold' ==? l:hifnt[2]
	let l:fnt['fntbold'] = 1
      endif
      if 'i' ==? l:hifnt[3] || 'o' ==? l:hifnt[3]
	let l:fnt['fntitlc'] = 1
      endif
      if !empty(l:hifnt[4]) && '0' != l:hifnt[4] && '*' != l:hifnt[4]
	let l:fnt['fntwdth'] = l:hifnt[4]
      endif
      if !empty(l:hifnt[7]) && '[' != l:hifnt[7][0:0] && '*' != l:hifnt[7]
	let l:fnt['fnthght'] = l:hifnt[7]
      endif
      return l:fnt
    elseif has ('gui_mac')
      let l:hifnt = tr(l:hifnt, '_', ' ')
      let l:hifnt = substitute(l:hifnt, '\', '', 'g')
      let l:cln = stridx(l:hifnt, ':')
      if 0 < l:cln
	let l:fnt['fntname'] = l:hifnt[0:l:cln-1]
      elseif 0 > l:cln
	let l:fnt['fntname'] = l:hifnt
      endif
      let l:sze = matchlist(l:fnt, '\C\(:' ..s:FNT_SIZE[0]..'\)\(\d\{1,}\)')
      if !empty(l:sze)
	let l:fnt['fnthght'] = l:sze[2]
      endif
      return l:fnt
    endif
  endif
  return -1
endfunction

function <SID>ParseHiArgs(grplnr)
  if !empty(a:grplnr)
    let l:hiattr = {}
    let l:str = getline(a:grplnr)
    for l:hiarg in s:HI_ARGS
      let @u = ''
      let l:pos = matchend(l:str, l:hiarg .. '=')
      if 0 <= l:pos
	if 'gui' == l:hiarg
	  let @u = <SID>GetEntry(0, a:grplnr, l:pos+1, 0, 'E')
	  let l:idx = 0
	  while !empty(@u) || l:idx < len(s:SPEC_ATTR)
	    if 0 <= (stridx(@u, s:SPEC_ATTR[l:idx][0]))
	      let l:hiattr[s:SPEC_ATTR[l:idx][1]] = 1
	      let @u =
		\ substitute(@u, s:SPEC_ATTR[l:idx][0]..'\%(,\|\s\)\=', '', '')
	    endif
	    let l:idx += 1
	  endwhile
	elseif 'guifg' == l:hiarg || 'guibg' == l:hiarg || 'guisp' == l:hiarg
	  let l:pos2 = match(l:str, '\%( gui\| font\|$\)', l:pos)
	  if 0 < l:pos2
	    let @u = <SID>GetEntry(0, a:grplnr, l:pos+1, 0, (l:pos2-l:pos)..'l')
	    if !empty(@u)
	      let @u = <SID>GetColor(@u)
	      if !empty(@u) && -1 != (@u+0)
		if 'guifg' == l:hiarg
		  let l:hiattr['fgco'] = getreg('u')
		elseif 'guibg' == l:hiarg
		  let l:hiattr['bgco'] = getreg('u')
		elseif 'guisp' == l:hiarg
		  let l:hiattr['spco'] = getreg('u')
		endif
	      endif
	    endif
	  endif
	elseif 'font' == l:hiarg
	  let @u = <SID>GetEntry(0, a:grplnr, l:pos+1, 0, 'g_')
	  if !empty(@u)
	    let l:fnt = <SID>ParseFont(@u)
	    if !empty(l:fnt) && type(0) != type(l:fnt)
	      let l:hiattr['font'] = l:fnt
	    endif
	  endif
	endif
      elseif s:is_norm && 'font' == l:hiarg
	let @u = colo2css#GetInitFont()
	if !empty(@u)
	  let l:fnt = <SID>ParseFont(@u)
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

function <SID>HiAttr2CssDecl(hiattrval)
  if !empty(a:hiattrval)
    let l:cssdecl = []
    let l:fnt = {}
    if has_key(a:hiattrval, 'font')
      let l:fnt = a:hiattrval['font']
    endif
    if !empty(l:fnt)
      if has_key(l:fnt, 'fntname')
	call add(l:cssdecl, 'font-family: "'..l:fnt['fntname']..'", monospace;')
      endif
      if has_key(l:fnt, 'fnthght')
	if has('gui_win32') || has('gui_gtk2') || has('gui_gtk3') || has('gui_mac')
	  call add(l:cssdecl, 'font-size: '..l:fnt['fnthght']..'pt;')
	elseif has('X11')
	  call add(l:cssdecl, 'font-size: '..(l:fnt['fnthght']/10)..'pt;')
	endif
      endif
      if has_key(l:fnt, 'fntwdt')
	if has('X11')
	  call add(l:cssdecl, 'font-stretch: '..(tr(l:fnt['fntwdt'], ' ', '-'))..';')
	endif
      endif
      if has_key(l:fnt, 'fntwght')
	    call add(l:cssdecl, 'font-weight: '..l:fnt['fntwght']..';')
      endif
      if get(l:fnt, 'fntbold')
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
    elseif s:is_norm
      call add(l:cssdecl, 'font-family: monospace;')
    endif
    if get(a:hiattrval, 'wght')
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
      let l:idx = match(l:cssdecl, 'font-style:')
      if 0 <= l:idx
	if 0 > match(l:cssdecl[l:idx], 'italic')
	  let l:cssdecl[l:idx] = 'font-style: italic;'
	endif
      else
	call add(l:cssdecl, 'font-style: italic;')
      endif
    endif
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
	let s:bg_norm = s:is_norm ? l:bgc : s:bg_norm
      endif
    elseif s:is_norm
      call add(l:cssdecl, 'background-color: transparent;')
      let s:bg_norm = '#FFFFFF'
    endif
    if has_key(a:hiattrval, 'fgco')
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
	let s:fg_norm = s:is_norm ? l:fgc : s:fg_norm
      endif
    elseif s:is_norm
      call add(l:cssdecl, 'color: inherit;')
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
      call add(l:cssdecl,
	    \ 'text-decoration: underline;'
	    \ .. ' -moz-text-decoration-line: underline; -moz-text-decoration-style: wavy;'
	    \ .. ' -webkit-text-decoration-line: underline; -webkit-text-decoration-style: wavy;'
	    \ .. ' text-decoration-line: underline; text-decoration-style: wavy;')
    endif
    if has_key(a:hiattrval, 'spco') && !s:is_norm
      let l:tdc = get(a:hiattrval, 'spco')
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
	  let @i = l:idx
	  let @f = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	endif
	let l:idx = match(l:cssdecl, 'background-color')
	if 0 <= l:idx
	  let @x = l:idx
	  let @b = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	endif
	if -1 != @i && -1 != @x
	  let l:cssdecl[@i] = 'color: ' .. @b .. ';'
	  let l:cssdecl[@x] = 'background-color: ' .. @f .. ';'
	elseif -1 != @i && -1 == @x
	  let l:cssdecl[@i] = 'color: ' .. s:bg_norm .. ';'
	  call add(l:cssdecl, 'background-color: ' .. @f .. ';')
	elseif -1 == @i && -1 != @x
	  call add(l:cssdecl, 'color: ' .. @b .. ';')
	  let l:cssdecl[@x] = 'background-color: ' .. s:fg_norm .. ';'
	elseif -1 == @i && -1 == @x
	  call add(l:cssdecl, 'color: ' .. s:bg_norm .. ';')
	  call add(l:cssdecl, 'background-color: ' .. s:fg_norm .. ';')
	endif
      else
	return -1
      endif
    endif
    if get(a:hiattrval, 'rset') && !s:is_norm
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
      if '' != s:fg_norm && '' != s:bg_norm
	let @i = -1
	let @f = ''
	let @x = -1
	let @b = ''
	let l:idx = match(l:cssdecl, '\<color')
	if 0 <= l:idx
	  let @i = l:idx
	  let @f = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	else
	  let @f = s:fg_norm
	endif
	let l:idx = match(l:cssdecl, 'background-color')
	if 0 <= l:idx
	  let @x = l:idx
	  let @b = matchstr(l:cssdecl[l:idx], '#\x\{6}')
	else
	  let @b = s:bg_norm
	endif
	if ('#FFFFFF' !=? @f) || ('#000000' !=? @b)
	  let @f = <SID>BrightColo(@f, 20, 'l')
	  let @b = <SID>BrightColo(@b, 10, 'd')
	else
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
    let l:cssdecl[0] = '{' .. l:cssdecl[0]
    let l:cssdecl[-1] = l:cssdecl[-1] .. '}'
    return l:cssdecl
  endif
  return -1
endfunction

function <SID>GetLnkGrp(grpname)
  if !empty(a:grpname)
    if !cursor(1,1)
      let l:srchpat = 'links to\s\+' .. a:grpname .. '$'
      let l:srchflgs = 'cnW'
      let l:lnkgrpnm = ''
      let l:lnr = 1
      while l:lnr
	let l:fndlnr = search(l:srchpat, l:srchflgs, line('$'))
	if l:fndlnr
	  let l:lnkgrpnm = <SID>GetEntry(0, l:fndlnr, 1, 0, 'iw')
	  if !empty(l:lnkgrpnm)
	    let @U = ' '..l:lnkgrpnm
	  endif
	  execute l:fndlnr'delete'
	  call <SID>GetLnkGrp(l:lnkgrpnm)
	endif
	let l:lnr = l:fndlnr
      endwhile
      return @U
    endif
  endif
  return -1
endfunction

function <SID>HiGrpNme2CssSel(grpname)
  if !empty(a:grpname)
    let l:csssel = ''
    let @u = ''
    let l:csssel = <SID>GetLnkGrp(a:grpname)
    if empty(l:csssel)
      let l:csssel = s:is_norm ? '*, .'..a:grpname : '.'..a:grpname
    elseif type(0) != type(l:csssel)
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

function <SID>HiGrpLn2CssRule(grpname, grplnr)
  if !empty(a:grpname) && (a:grplnr || s:is_norm)
    let l:cssrule = []
    let l:comgrp = a:grpname
    let l:fndlnr = a:grplnr
    call setpos('.', [0, l:fndlnr, 1, 0])
    while (search('links to ', 'cnW', l:fndlnr) == l:fndlnr)
      let l:n = (matchlist(getline(l:fndlnr), '\(links to \)\(\w\+\)'))[2]
      if l:comgrp ==? l:n
	let l:pos = match(getline('.'), 'links to ')
	call setpos('.', [0, l:fndlnr, l:pos, 0])
	normal d$
	break
      endif
      call setpos('.', [0, 1, 1, 0])
      let l:nfndlnr = search('^\<' ..l:n.. '\>', 'cW', line('$'))
      if !l:nfndlnr
	execute l:fndlnr'delete'
	return -1
      endif
      let l:comgrp = l:n
      let l:fndlnr = l:nfndlnr
      call setpos('.', [0, l:fndlnr, 1, 0])
    endwhile
    let l:csssel = <SID>HiGrpNme2CssSel(l:comgrp)
    if !empty(l:csssel) && type(0) != type(l:csssel)
      call setpos('.', [0, 1, 1, 0])
      let l:fndlnr = search('^\<' ..l:comgrp.. '\>', 'cW', line('$'))
      let l:hiattr = <SID>ParseHiArgs(l:fndlnr)
      if !empty(l:hiattr) && type(0) != type(l:hiattr)
	let l:cssdecl = <SID>HiAttr2CssDecl(l:hiattr)
	if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
	  call insert(l:cssrule, l:csssel)
	  let l:cssrule += l:cssdecl
	endif
      endif
    endif
    call deletebufline(s:NME_TMP_BUF, l:fndlnr)
    return l:cssrule
  endif
  return -1
endfunction

function! colo2css#MainColo2Css(colofls, bgr, outdir, fnt)
  if !empty(a:bgr)
    let s:old_val = {'&bg':&bg}
    execute('set background='..a:bgr)
  endif
  if !empty(a:colofls[0])
    if !empty(a:fnt)
      let &guifont = a:fnt
      if has('X11')
	let &guifontset = a:fnt
      endif
    endif
    set lines=999 columns=9999 eventignore=all
  endif
  for l:clch in a:colofls
    if empty(l:clch)
      if !has('gui')
	exe "normal \<Esc>"
	echoerr "Работа подключаемого модуля возможна только в графической оболочке (ГИП, GUI)"
	return -1
      endif
      call extend(s:old_val, {
	    \ '&hidden':&hidden,
	    \ '&lazyredraw':&lazyredraw,
	    \ '&more':&more,
	    \ '&report':&report,
	    \ '&shortmess':&shortmess,
	    \ '&wrapscan':&wrapscan,
	    \ '&showcmd':&showcmd,
	    \ '&ruler':&ruler,
	    \ '&spell':&spell,
	    \ '&whichwrap':&whichwrap,
	    \ '&textwidth':&textwidth,
	    \ '&verbose':&verbose,
	    \ '@e':@e,
	    \ '@u':@u,
	    \ '@i':@i,
	    \ '@x':@x,
	    \ '@f':@f,
	    \ '@b':@b,
	    \ '@/':@/,
	    \ })
      if line("$") != 1 || getline(1) != ""
	new
      endif
      augroup colo2css
	autocmd BufWipeout Tmp_Colo2CSS call<SID>CleanUp(s:old_val)
	      \ | delfunction <SID>CleanUp
      augroup END
    else
      highlight clear Normal
      highlight clear
      syntax reset
      syntax clear
      execute('silent colorscheme ' .. l:clch)
    endif
    call <SID>HiGroups2Buf()
    if bufexists(s:NME_TMP_BUF)
      let l:cssentries = []
      let s:is_norm = 1
      for l:grpname in s:INIT_GRP
	call setpos('.', [0, 1, 1, 0])
	let l:fndlnr = search('^\<' ..l:grpname.. '\>', 'cW', line('$'))
	if (!l:fndlnr && s:is_norm) || l:fndlnr
	  let l:cssrule = <SID>HiGrpLn2CssRule(l:grpname, l:fndlnr)
	  if !empty(l:cssrule) && type(0) != type(l:cssrule)
	    call add(l:cssentries, l:cssrule)
	  endif
	endif
	let s:is_norm = 0
      endfor
      while getline(1) != ""
	let l:fndlnr = line('.')
	let l:grpname = <SID>GetEntry(0, l:fndlnr, 1, 0, 'iw')
	if empty(l:grpname)
	  execute l:fndlnr'delete'
	  continue
	else
	  let l:cssrule = <SID>HiGrpLn2CssRule(l:grpname, l:fndlnr)
	  if !empty(l:cssrule) && type(0) != type(l:cssrule)
	    call add(l:cssentries, l:cssrule)
	  endif
	endif
      endwhile
      if !empty(l:cssentries)
	let l:css_head = []
	if empty(l:clch)
	  let l:coloschm = (trim(execute('colorscheme')))
	  if 0<=match(l:coloschm, '\cE121:')
	    let l:coloschm = 'unknown'
	  endif
	else
	  let l:coloschm = l:clch
	endif
	call add(l:css_head,
	  \ '/* Этот файл CSS создан в программе Vim версии '
	  \ .. v:version/100 .. '.' .. v:version%100 .. '.'
	  \ .. v:versionlong % float2nr(pow(10, (len(v:versionlong)-len(v:version)))) .. ' */')
	call add(l:css_head,
	  \ '/* из файла цветовой схемы «' .. l:coloschm .. '» */')
	call add(l:css_head,
	  \ '/* Для этого был использован подключаемый модуль «colo2css.vim» */')
	call add(l:css_head, ' ')
	call chdir(a:outdir)
	let l:flnm = l:coloschm .. '_' .. &background .. '.css'
	call writefile(map(l:css_head, 'v:val .. "\r"'), l:flnm)
	for l:cssln in l:cssentries
	  call writefile(map(l:cssln, 'v:val .. "\r"'), l:flnm, 'a')
	endfor
      endif
      execute 'bwipeout! ' s:NME_TMP_BUF
      redraw!
    else
      return -1
    endif
  endfor
  if !empty(l:clch)
    0cquit!
  endif
endfunction

function <SID>CleanUp(oldval)
  for [l:key, l:val] in items(a:oldval)
    exe 'let ' .. l:key .. ' = ' .. '"' .. l:val .. '"'
  endfor
  unlet! s:NOT_RGB s:WINSYS_COLO s:FNT_SIZE s:SPEC_ATTR s:HI_ARGS s:INIT_GRP
  unlet! s:NME_TMP_BUF s:is_norm s:bg_norm s:fg_norm s:old_val
  delfunction <SID>HiGroups2Buf
  delfunction <SID>GetEntry
  delfunction <SID>GetLnkGrp
  delfunction <SID>Dec2Hex
  delfunction <SID>ColoStr2ColoNum
  delfunction <SID>GetColor
  delfunction <SID>ParseFont
  delfunction <SID>ParseHiArgs
  delfunction <SID>HiAttr2CssDecl
  delfunction <SID>HiGrpNme2CssSel
  delfunction <SID>HiGrpLn2CssRule
  delfunction <SID>RGB2HSB
  delfunction <SID>HSB2RGB
  delfunction <SID>BrightColo
  au! colo2css
endfunction

let &cpo = s:old_set
unlet s:old_set


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file colo2css.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
plugin\LnchC2C.vim	[[[1
134
" LnchC2C.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorers@users.sf.net>
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
doc\colo2css.rux	[[[1
160
*ColorScheme2CSS.txt*     Преобразование цветовых схем программы Vim в файлы CSS


Disclaimer on the text:
The English text is contained in the file colo2css.txt


Содержание

1. Обзор подключаемого модуля			|overview-colo2css|
2. Установка подключаемого модуля		|installing-colo2css|
3. Использование подключаемого модуля		|using-colo2css|
4. Обратная связь				|feddback|
5. Лицензия и авторские права			|license|


Преобразования цветовых схем программы «Редактор Vim» в готовые файлы CSS.


==============================================================================
1. Обзор подключаемого модуля			*overview-colo2css*

Данный подключаемый модуль предназначен для преобразования текущей цветовой
схемы программы «Редактор Vim» в готовый файл «каскадной таблицы стилей»
(Cascading Style Sheets, CSS). Файлы CSS, подготовленные этим подключаемым
модулем, соответствуют требованиям CSS Validation Service
(https://jigsaw.w3.org/css-validator/) и могут быть использованы для
подключения к документу (веб‐странице) HTML или XHTML. 

Подключаемый модуль может быть использован как для преобразования только
текущей цветовой схемы, так и для пакетной обработки нескольких файлов
цветовых схем редактора Vim.

При конвертации цветовой схемы можно задать требуемый фон — тёмный или светлый
(dark or light). Также возможно указать каталог, куда будут записаны готовые
файлы CSS.

Для работы этого подключаемого модуля требуется программа Vim версии 8.2 или
старше. Для преобразования цветовых схем используется вариант программы с
поддержкой графического интерфейса пользователя (ГИП, graphical user
interface, GUI).

==============================================================================
2. Установка подключаемого модуля		*installing-colo2css*

Перед началом использования данного подключаемого модуля требуется разместить
поставляемые в его комплекте файлы в соответствующие каталоги. В комплект
поставки этого модуля входят следующие файлы:

colo2css.vim — основной файл подключаемого модуля. Должен быть размещён в
	       подкаталоге «|autoload|» одного из каталогов, указанных в
	       значении параметра 'runtimepath';
LnchC2C.vim  — файл, предназначенный для запуска основного файла модуля.
	       Должен быть размещён в подкаталоге «|plugin|» одного из
	       каталогов, указанных в значении параметра 'runtimepath';
colo2css.txt — файл документации на английском языке к этому модулю. Должен
	       быть размещён в подкаталоге «doc». См. |add-local-help|;
colo2css.rux — файл документации на русском языке к этому модулю. Должен быть
	       размещён в подкаталоге «doc». См. |add-local-help|.

Если этот подключаемый модуль получен в виде готового пакета colo2css.vba.zip,
то установка указанных файлов будет выполнена автоматически. Подробнее об
использовании установочных пакетов смотрите раздел |pi_vimball.txt| и |packages|.

При самостоятельной установке этого подключаемого модуля вручную, разместите
указанные выше файлы в соответствующие каталоги, и перезапустите программу Vim.

==============================================================================
3. Использование подключаемого модуля		*using-colo2css*

После установки этого подключаемого модуля как описано в предыдущем параграфе,
модуль готов к использованию. Для его запуска необходимо в командной строке
редактора Vim набрать команду

>
	TOcss
<

После нажатия клавиши <ENTER> будет создан файл CSS для текущей цветовой схемы
в подкаталоге «Colo2CSS» домашнего каталога пользователя.

Чтобы использовать этот подключаемый модуль в расширенном режиме, необходимо
указать поддерживаемые этой командой аргументы. Аргументы команды разделяются
пробелом.

Аргументы команды:

	:TOcss [[ALL | list_files] [dark | light] [outdir]] ~
где
 ALL		    Преобразовать все файлы цветовых схем, находящиеся в
		    подкаталоге «color» и расположенном в каталогах, указанных
		    в параметре 'runtimepath' и 'packpath'.
 list_files	    Перечень файлов цветовых схем, которые требуется
		    преобразовать в файлы CSS. Если указано более одного
		    файла, то файлы разделяются символом запятой без пробелов.
		    В наименовании файлов не допускаются запятые и пробелы.
 dark или light	    Фон, применяемый для цветовых схем при их загрузке в
		    редактор Vim и последующей конвертации.
 outdir		    Каталог для готовых файлов CSS. Задаётся как абсолютный
		    маршрут. Каталог должен существовать и быть доступен для
		    записи. По умолчанию используется автоматически
		    создаваемый подкаталог «Colo2CSS» в каталоге пользователя.

Примеры:

>
	TOcss light
<

Будет выполнено преобразование текущей цветовой схемы с использованием
светлого фона. Результат будет сохранён в каталог ~/Colo2CSS (если этот
каталог отсутствует, то он будет создан автоматически в домашнем каталоге
пользователя).

>
	TOcss ALL d:\project\myhomepage\css
<

Будет выполнено преобразование всех файлов цветовых схем, а готовые файлы CSS
сохранены в каталог «css», расположенный по маршруту d:\project\myhomepage.
Аргумент ALL указывается только прописными буквами. Каталог должен уже
существовать и быть доступен для записи. Если этого каталога нет, то результат
будет сохранён в каталоге C:\Users\<username>\Colo2CSS.

>
	TOcss darkblue.vim,mustang,PaperColor.vim,desert dark e:\colorscheme
<

Будет выполнено преобразование указанных файлов с включённым тёмным фоном, и
результат сохранён в «e:\colorscheme». Наименования файлов цветовых схем можно
указывать как с расширением «.vim», так и без него. Файлы отделяются друг от
друга символом запятой, пробелы и запятые в наименовании файлов не допустимы.
Между наименованием файла и символом запятой не должно быть пробела.

==============================================================================
4. Обратная связь				*feddback*

Если есть пожелания, дополнения или замечания по работе этого подключаемого
модуля, связаться с автором можно по электронной почте:
mailto:restorers@users.sourceforge.net
Также можно оставить свои пожелания на веб‐странице этого подключаемого модуля:
https://github.com/RestorerZ/Colo2CSS
В этом же хранилище можно получить новые версии подключаемого модуля и
ознакомиться с его исходным кодом.

==============================================================================
5. Лицензия					*license*

Для этого подключаемого модуля и всех его компонентов действует лицензия
Mozilla Public License, v. 2.0, http://mozilla.org/MPL/2.0/
С текстом лицензии можно ознакомиться в файле LICENSE.txt, поставляемом с
данным подключаемым модулем или по указанной выше ссылке. Авторские права на
данный подключаемый модуль, его компоненты и документации к нему принадлежат
автору Павлу Витальевичу З. (псевдоним Restorer). Авторские права на сторонние
компоненты и их торговые марки, использованные в этом подключаемом модуле,
принадлежат их владельцам.



 vim:ft=help:tw=78:ts=8:noet:norl:
doc\colo2css.txt	[[[1
159
*ColorScheme2CSS.txt*		Converting color schemes of Vim to CSS files


Оговорка по тексту:
This is a machine translation of the Яandex service. I apologize for possible
mistakes.
Для тех, кто думает по‐русски (говорит и пишет) есть файл colo2css.rux


Table of contents

1. Overview of the plugin			|overview-colo2css|
2. Installing the plugin			|installing-colo2css|
3. Using the plugin				|using-colo2css|
4. Feedback					|feddback|
5. License and Copyright			|license|


Converting color schemes of the program Vim editor into ready-made CSS files.


==============================================================================
1. Overview of the plugin			*overview-colo2css*

This plugin is designed to convert the current color scheme of the program
Vim Editor into a ready-made Cascading Style Sheets (CSS) file. The CSS files
prepared by this plugin meet the requirements CSS Validation Service
(https://jigsaw.w3.org/css-validator/) and can be used to connect to an HTML
or XHTML document (web page).

The plugin can be used both for converting only the current color scheme, and
for batch processing of several files of color schemes of the Vim editor.

When converting a color scheme, you can set the desired background — dark or
light. It is also possible to specify the directory where the finished CSS
files will be written.

This plugin requires a program Vim version 8.2 or older to work. To convert
color schemes, a variant of the program with support for a graphical user
interface (GUI) is used.

==============================================================================
2. Installing the plugin			*installing-colo2css*

Before using this plugin, it is required to place the files supplied in its
package in the appropriate directories. The following files are included in
the package of this module:

colo2css.vim — is the main file of the plugin. Must be placed in the
	       "|autoload|" subdirectory of one of the directories specified
	       in the value of the 'runtimepath' parameter.
LnchC2C.vim  — file designed to run the main module file. Must be placed in the
	       "|plugin|" subdirectory of one of the directories specified in
	       the value of the 'runtimepath' parameter.
colo2css.txt - documentation file in English for this module. It should be
	       placed in the "doc" subdirectory. See |add-local-help|.
colo2css.rux - the documentation file in Russian for this module. Must be
	       placed in the "doc" subdirectory. See |add-local-help|

If this plugin is received as a ready-made package colo2css.vba.zip, then the
installation of the specified files will be performed automatically. For more
information about using installation packages, see the section
|pi_vimball.txt| and |packages|.

If you install this plugin manually yourself, place the above files in the
appropriate directories, and restart the Vim program.

==============================================================================
3. Using the plugin				*using-colo2css*

After installing this plugin as described in the previous paragraph, the
module is ready for use. To run it, you need to type the command in the
command line of the Vim editor

>
	TOcss
<

After pressing the <ENTER> key, a CSS file for the current color scheme will
be created in the "Colo2CSS" subdirectory of the user's home directory.

To use this plugin in extended mode, you must specify the arguments supported
by this command. The command arguments are separated by a space.

Command arguments:

	:TOcss [[ALL | list_files] [dark | light] [outdir]] ~

where
 ALL		    Convert all color scheme files located in the "color"
		    subdirectory and located in the directories specified in
		    the 'runtimepath' and 'packpath' parameter.
 list_files	    Is a list of color scheme files that you want to convert
		    to CSS files. If more than one file is specified, the
		    files are separated by a comma without spaces. Commas and
		    spaces are not allowed in the file names.
 dark or light	    Background used for color schemes when they are loaded
		    into the Vim editor and then converted.
 outdir		    Directory for ready-made CSS files. Set as an absolute
		    route. The directory must exist and be writable. By
		    default, the automatically created "Colo2CSS" subdirectory
		    in the user's directory is used.

Examples:

>
	TOcss light
<

The current color scheme will be converted using a light background. The
result will be saved to the ~/Colo2CSS directory (if this directory is
missing, it will be created automatically in the user's home directory).

>
	TOcss ALL d:\project\myhomepage\css
<

All color scheme files will be converted, and the finished CSS files will be
saved to the "css" directory located along route d:\project\myhomepage. The
ALL argument is specified only in uppercase letters. The directory must
already exist and be writable. If this directory does not exist, the result
will be saved in the directory C:\Users\<username>\Colo2CSS.

>
	TOcss darkblue.vim,mustang,PaperColor.vim,desert dark e:\colorscheme
<

The conversion of the specified files with the dark background enabled will be
performed, and the result will be saved in "e:\colorscheme". The names of the
color scheme files can be specified with or without the ".vim" extension.
Files are separated from each other by a comma, spaces and commas in the file
names are not allowed. There should be no space between the file name and the
comma symbol.

==============================================================================
4. Feedback					*feddback*

If you have any suggestions, additions or comments on the work of this
plugin, you can contact the author by e-mail:
mailto:restorers@users.sourceforge.net
You can also leave your wishes on the web page of this plugin:
https://github.com/RestorerZ/Colo2CSS
In the same repository, you can get new versions of the plugin and get
acquainted with its source code.

==============================================================================
5. License					*license*

The Mozilla Public License, v. 2.0, http://mozilla.org/MPL/2.0/, is valid for
this plugin and all its components.
The license text can be found in the file LICENSE.txt, supplied with this
plugin or via the link above. The copyright for this plugin, its components
and documentation to it belong to the author Pavel Vitalyevich Z. (nikname
Restorer). The copyrights of third-party components and their trademarks used
in this plugin belong to their owners.



vim:ft=help:tw=78:ts=8:noet:norl:
