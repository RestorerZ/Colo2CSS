" colo2css.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer
" Last change:	25 Dec 2021
" Version:	1.5.9
" Description:	преобразование цветовой схемы Vim в файл CSS
"		converting a Vim color scheme to a CSS file



" Цвета, которые отсутствуют в файле rgb.txt. Взято из файла src\term.c 
let s:not_rgb =
  \ [['darkyellow','8B8B00'],['lightmagenta','FF8BFF'],['lightred','FF8B8B']]


" *win32-colors*
" https://russianblogs.com/article/8427240475/
" http://rusproject.narod.ru/winapi/g/getsyscolor.html
" https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
let s:winsys_colo = {
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


let s:fnt_size = ['h', 'w', 'W']


let s:hi_args = ['gui', 'guifg', 'guibg', 'guisp', 'font']


let s:spec_attr = [['bold', 'wght'], ['italic', 'itlc'],
  \ ['underline', 'undlne'], ['undercurl', 'undcrl'],
  \ ['reverse', 'rvrs'], ['inverse', 'rvrs'],
  \ ['strikethrough', 'skthro'], ['NONE', 'rset'],
  \ ['standout', 'lum'], ['nocombine', 'ncomb']]


" Группы подсветки, используемые по умолчанию. Взято из *highlight-default*
" Группа «Normal» должна быть первой, т. к. это будут общие параметры CSS
let s:init_grp = ['Normal', 'ColorColumn', 'Conceal', 'Cursor', 'CursorColumn',
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


" Общие переменные
let s:nme_tmp_buf = 'Tmp_Colo2CSS'
let s:is_norm = 0
let s:bg_norm = ''
let s:fg_norm = ''
let s:old_set = {}



function s:HiGroups2Buf()
  " cmdheight=998
  set hidden lazyredraw nomore report=99999 shortmess=aAoOsStTWIcF nowrapscan
"  set noshowcmd noruler nospell lines=999 columns=9999 eventignore=all  whichwrap&
  set noshowcmd noruler nospell whichwrap&
  redir @u
  silent highlight
  redir END
"  if line("$") != 1 || getline(1) != ""
"    new
"  endif
  execute 'edit ' .. s:nme_tmp_buf
  setlocal noautoindent noexpandtab formatoptions=""
  setlocal noswapfile
  setlocal buftype=nofile
  let &textwidth=&columns
  put u
  silent! global/ cleared$/delete
  %substitute/xxx //e
" silent! global/^\s*links to \w\+/.-1join
  silent! global/^\s\+\w\+/.-1join
  silent! global/^\s*$/delete
endfunction

function s:GetEntry(bnr, lnr, cnr, offset, motion)
  let @u = ''
  if !setpos('.', [a:bnr, a:lnr, a:cnr, a:offset])
    execute 'normal "uy' .. a:motion
  endif
  return getreg('u')
endfunction

function s:Dec2Hex(str)
  let l:hexdig=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
  let l:hex=''
  let l:num=str2nr(a:str, 10)
  if !l:num
    return l:num
  else
    while l:num
      let l:hex=l:hexdig[l:num%16] .. l:hex
      let l:num/=16
  endwhile
  endif
  return l:hex
endfunction

function s:RGB2HSB(hexcolo)
" Проверка входных параметров
  if !empty(a:hexcolo) && (6 == len(a:hexcolo))
    let l:rr = str2nr(a:hexcolo[0:1], 16)
    let l:gg = str2nr(a:hexcolo[2:3], 16)
    let l:bb = str2nr(a:hexcolo[4:5], 16)
    let l:max = max([l:rr, l:gg, l:bb])
    let l:min = min([l:rr, l:gg, l:bb])
" Приводим к диапазону значений [0,1] и одновременно преобразуем к типу float
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

function s:HSB2RGB(h, s, b)
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

function s:BrightColo(hexcolo, prcnt, lord)
  let l:hexcolo = ''
  let l:colo = trim(a:hexcolo, '#', 1)
  let l:prcnt = (100 < a:prcnt ? 100 : 0 > a:prcnt ? 0 : a:prcnt)
  let l:hsb = s:RGB2HSB(l:colo)
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
  let l:rgb = s:HSB2RGB(l:hsb[0], l:hsb[1], l:hsb[2])
  let @u = ''
  for l:cc in l:rgb
    let @u = s:Dec2Hex(l:cc)
    if 255 < str2nr(@u, 16)
      return -1
    endif
    if 2 != len(@u)
      let @u = 0 .. @u
    endif
    let l:hexcolo = l:hexcolo .. @u
  endfor
  return '#' .. l:hexcolo
endfunction

function s:ColoStr2ColoNum(colostr)
  if !empty(a:colostr)
    for l:nrgb in s:not_rgb
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
\ .. s:winsys_colo[toupper(a:colostr)][0] .. " ^| Select-Object -ExpandProperty "
\ .. s:winsys_colo[toupper(a:colostr)][0])
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
	let @u = s:Dec2Hex(@u)
	if 255 < str2nr(@u, 16)
	  return -1
	endif
	if 2 != len(@u)
	  let @u = 0 ..@u
	endif
	let l:hexcolo = l:hexcolo .. @u
      endwhile
      return l:hexcolo
    endif
  endif
  return -1
endfunction

function s:GetColor(coloval)
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
      let @u = s:ColoStr2ColoNum(a:coloval)
      if !empty(@u) && -1 != (@u+0)
	return '#' .. @u
      endif
    endif
  endif
  return -1
endfunction

function s:GetInitFont()
  let @u = ''
  let @u = getfontname()
  if empty(@u)
    let @u = &guifont
    if !empty(@u)
      let l:cmm = match(@u, '\w,')
      if 0 < l:cmm
	let @u = strpart(@u, 0, l:cmm)
      endif
    endif
  endif
  return getreg('u')
endfunction

function s:ParseFont(fntval)
  if !empty(a:fntval)
    let l:fnt = {}
    if 'NONE' ==? a:fntval
      let l:hifnt = s:GetInitFont()
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
      for l:fntsze in s:fnt_size
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
      let l:sze = matchlist(l:fnt, '\C\(:' ..s:fnt_size[0]..'\)\(\d\{1,}\)')
      if !empty(l:sze)
	let l:fnt['fnthght'] = l:sze[2]
      endif
      return l:fnt
    endif
  endif
  return -1
endfunction

function s:ParseHiArgs(grplnr)
  if !empty(a:grplnr)
    let l:hiattr = {}
    let l:str = getline(a:grplnr)
    for l:hiarg in s:hi_args
      let @u = ''
      let l:pos = matchend(l:str, l:hiarg .. '=')
      if 0 <= l:pos
	if 'gui' == l:hiarg
	  let @u = s:GetEntry(0, a:grplnr, l:pos+1, 0, 'E')
	  let l:idx = 0
	  while !empty(@u) || l:idx < len(s:spec_attr)
	    if 0 <= (stridx(@u, s:spec_attr[l:idx][0]))
	      let l:hiattr[s:spec_attr[l:idx][1]] = 1
	      let @u =
		\ substitute(@u, s:spec_attr[l:idx][0]..'\%(,\|\s\)\=', '', '')
	    endif
	    let l:idx += 1
	  endwhile
	elseif 'guifg' == l:hiarg || 'guibg' == l:hiarg || 'guisp' == l:hiarg
	  let l:pos2 = match(l:str, '\%( gui\| font\|$\)', l:pos)
	  if 0 < l:pos2
	    let @u = s:GetEntry(0, a:grplnr, l:pos+1, 0, (l:pos2-l:pos)..'l')
	    if !empty(@u)
	      let @u = s:GetColor(@u)
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
" ПРАВЬ: подумай над границами этого условия
	  endif
	elseif 'font' == l:hiarg
	  let @u = s:GetEntry(0, a:grplnr, l:pos+1, 0, 'g_')
	  if !empty(@u)
	    let l:fnt = s:ParseFont(@u)
	    if !empty(l:fnt) && type(0) != type(l:fnt)
	      let l:hiattr['font'] = l:fnt
	    endif
	  endif
	endif
      elseif s:is_norm && 'font' == l:hiarg
	let @u = s:GetInitFont()
	if !empty(@u)
	  let l:fnt = s:ParseFont(@u)
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

function s:HiAttr2CssDecl(hiattrval)
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
		\ '-moz-text-decoration-color: ' .. s:bg_norm .. ';'
		\ .. ' -webkit-text-decoration-color: ' .. s:bg_norm .. ';'
		\ .. ' text-decoration-color: ' .. s:bg_norm .. ';')
	else
	  return -1
	endif
      elseif 'fg' ==? l:tdc
	if '' != s:fg_norm
	  call add(l:cssdecl,
		\ '-moz-text-decoration-color: ' .. s:fg_norm .. ';'
		\ .. ' -webkit-text-decoration-color: ' .. s:fg_norm .. ';'
		\ .. ' text-decoration-color: ' .. s:fg_norm .. ';')
	else
	  return -1
	endif
      else
	call add(l:cssdecl, '-moz-text-decoration-color: ' .. l:tdc .. ';'
	  \ .. ' -webkit-text-decoration-color: ' .. l:tdc .. ';'
	  \ .. ' text-decoration-color: ' .. l:tdc .. ';')
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
	  let @f = matchstr(l:cssdecl[l:idx], '#\x\+')
	endif
	let l:idx = match(l:cssdecl, 'background-color')
	if 0 <= l:idx
	  let @x = l:idx
	  let @b = matchstr(l:cssdecl[l:idx], '#\x\+')
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
	  let @f = matchstr(l:cssdecl[l:idx], '#\x\+')
	else
	  let @f = s:fg_norm
	endif
	let l:idx = match(l:cssdecl, 'background-color')
	if 0 <= l:idx
	  let @x = l:idx
	  let @b = matchstr(l:cssdecl[l:idx], '#\x\+')
	else
	  let @b = s:bg_norm
	endif
	if ('#FFFFFF' !=? @f) || ('#000000' !=? @b)
	  let @f = s:BrightColo(@f, 20, 'l')
	  let @b = s:BrightColo(@b, 10, 'd')
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
    if get(a:hiattrval, 'ncomb')
" что‐то делаем
    endif
    let l:cssdecl[0] = '{' .. l:cssdecl[0]
    let l:cssdecl[-1] = l:cssdecl[-1] .. '}'
    return l:cssdecl
  endif
  return -1
endfunction

function s:GetLnkGrp(grpname)
  if !empty(a:grpname)
    if !cursor(1,1)
      let l:srchpat = 'links to\s\+' .. a:grpname .. '$'
      let l:srchflgs = 'cnW'
      let l:lnkgrpnm = ''
      let l:lnr = 1
      while l:lnr
	let l:fndlnr = search(l:srchpat, l:srchflgs, line('$'))
	if l:fndlnr
	  let l:lnkgrpnm = s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
	  if !empty(l:lnkgrpnm)
	    let @U = ' '..l:lnkgrpnm
	  endif
	  execute l:fndlnr'delete'
	  call s:GetLnkGrp(l:lnkgrpnm)
	endif
	let l:lnr = l:fndlnr
      endwhile
      return @U
    endif
  endif
  return -1
endfunction

function s:HiGrpNme2CssSel(grpname)
  if !empty(a:grpname)
    let l:csssel = ''
    let @u = ''
    let l:csssel = s:GetLnkGrp(a:grpname)
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

function s:HiGrpLn2CssRule(grpname, grplnr)
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
    let l:csssel = s:HiGrpNme2CssSel(l:comgrp)
    if !empty(l:csssel) && type(0) != type(l:csssel)
      call setpos('.', [0, 1, 1, 0])
      let l:fndlnr = search('^\<' ..l:comgrp.. '\>', 'cW', line('$'))
      let l:hiattr = s:ParseHiArgs(l:fndlnr)
      if !empty(l:hiattr) && type(0) != type(l:hiattr)
	let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
	if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
	  call insert(l:cssrule, l:csssel)
	  let l:cssrule += l:cssdecl
	endif
      endif
      call deletebufline(s:nme_tmp_buf, l:fndlnr)
    endif
    return l:cssrule
  endif
  return -1
endfunction

function! MainColo2Css(colofls, bgr, outdir)
  if !empty(a:bgr)
    execute('set background='..a:bgr)
  endif
  for l:clch in a:colofls
    if empty(l:clch)
:let s:old_set = {
      \ '&more':&more,
      \ '&report':&report,
      \ '&lazyredraw':&lazyredraw,
      \ '&shortmess':&shortmess,
      \ '&spell':&spell,
      \ '&wrapscan':&wrapscan,
      \ '&whichwrap':&whichwrap,
      \ '&showcmd':&showcmd,
      \ '&ruler':&ruler,
      \ '@u':@u,
      \ '@i':@i,
      \ '@x':@x,
      \ '@f':@f,
      \ '@b':@b,
      \}
  if line("$") != 1 || getline(1) != ""
    new
  endif
    else
      set lines=999 columns=9999 eventignore=all
"      highlight clear Normal
      highlight clear
"      syntax reset
"      syntax clear
"      syntax off
"      syntax enable
      execute('silent colorscheme ' .. l:clch)
    endif
    call s:HiGroups2Buf()
"      set more
    if bufexists(s:nme_tmp_buf)
      let l:cssentries = []
      let s:is_norm = 1
      for l:grpname in s:init_grp
	call setpos('.', [0, 1, 1, 0])
	let l:fndlnr = search('^\<' ..l:grpname.. '\>', 'cW', line('$'))
	if (!l:fndlnr && s:is_norm) || l:fndlnr
	  let l:cssrule = s:HiGrpLn2CssRule(l:grpname, l:fndlnr)
	  if !empty(l:cssrule) && type(0) != type(l:cssrule)
	    call add(l:cssentries, l:cssrule)
	  endif
	endif
	let s:is_norm = 0
      endfor
      while getline(1) != ""
	let l:fndlnr = line('.')
	let l:grpname = s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
	if empty(l:grpname)
	  execute l:fndlnr'delete'
	  continue
	else
	  let l:cssrule = s:HiGrpLn2CssRule(l:grpname, l:fndlnr)
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
	    \ .. substitute(v:versionlong, '^'..v:version, '', '') ..' */')
	"\ .. v:versionlong % float2nr(pow(10, (len(v:versionlong)-len(v:version)))) .. ' */')
	call add(l:css_head,
	    \ '/* из файла цветовой схемы «' .. l:coloschm .. '» */')
	call add(l:css_head,
	    \ '/* Для этого был использован подключаемый модуль «colo2css.vim» */')
	call add(l:css_head, ' ')
	call chdir(a:outdir)

	let l:flnm =
	    \ l:coloschm
	    \ .. '_' .. &background .. '-' ..
	    \ strftime("%d%m%Y%H%M%S", localtime())
	    \ .. '.css'
	call writefile(map(l:css_head, 'v:val .. "\r"'), l:flnm)
	for l:cssln in l:cssentries
	  call writefile(map(l:cssln, 'v:val .. "\r"'), l:flnm, 'a')
	endfor
      endif
    else
      return -1
    endif
    redraw!
    execute 'bwipeout! ' s:nme_tmp_buf
  endfor
  if !empty(l:clch)
"    quit
  else
    call s:CleanUp(s:old_set)
  endif
endfunction

function! s:CleanUp(oldval)
  for [key, val] in items(a:oldval)
    exe 'let ' .. key .. ' = ' .. '"' .. val .. '"'
  endfor
"  execute 'bwipeout!' s:nme_tmp_buf
  unlet! s:not_rgb s:winsys_colo s:fnt_size s:spec_attr s:hi_args s:init_grp
  unlet! s:nme_tmp_buf s:is_norm s:bg_norm s:fg_norm
  delfunction s:HiGroups2Buf
  delfunction s:GetEntry
  delfunction s:GetLnkGrp
  delfunction s:Dec2Hex
  delfunction s:ColoStr2ColoNum
  delfunction s:GetColor
  delfunction s:GetInitFont
  delfunction s:ParseFont
  delfunction s:ParseHiArgs
  delfunction s:HiAttr2CssDecl
  delfunction s:HiGrpNme2CssSel
  delfunction s:HiGrpLn2CssRule
  delfunction s:RGB2HSB
  delfunction s:HSB2RGB
  delfunction s:BrightColo
"  delfunction MainColo2Css
"    delfunction s:CleanUp
"return | delfunction s:CleanUp
endfunction

"call

if has('user_commands')
  command! -nargs=* TOcss call <SID>Launch(<f-args>)
endif

function <SID>GetArgs(...)
  let l:inargs = a:000[0]
  let l:outargs = [[], '', '']
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
  endif
" проверяем какой фон задан
"  if empty(l:outargs[1])
"	let l:outargs[1] = ""
"  endif
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



function! <SID>Launch(...)
  let l:args = <SID>GetArgs(a:000)
" проверяем, есть ли файлы цветовых схем
  if empty(l:args[0][0])
    silent! runtime plugin/colo2css.vim
    call MainColo2Css(l:args[0], l:args[1], l:args[2])
  else
"    let g:jb = job_start(
	"\ 'gvim.exe -u NORC -U NONE -i NONE -N -n -c "call MainColo2Css('
	"\ ..string(l:args[0])..','..string(l:args[1])..','..string(l:args[2])
	"\ ..')"')
"    silent !start /b gvim.exe -u NORC -U NONE -i NONE -N -n -S e:\Programs/vim/vimfiles/plugin/colo2css.vim -c "call MainColo2Css(['blue'],'','')"
    silent execute(
	"\ '!start /b gvim.exe -u NONE -U NONE -i NONE -N -n -S e:\Programs/vim/vimfiles/plugin/colo2css.vim -c "call MainColo2Css('
	\ '!start /b gvim.exe -u NORC -U NONE -i NONE -N -n -c "call MainColo2Css('
	\ ..string(l:args[0])..','..string(l:args[1])..','..string(l:args[2])
	\ ..')"')
  endif
endfunction
