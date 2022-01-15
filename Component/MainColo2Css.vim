" MainColo2Css.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	15 Jan 2022
" Version:	1.7.12
" Description:	основная функция преобразования цветовой схемы в файл CSS
"		the main function of converting a color scheme to a CSS file
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/





" Группы подсветки, используемые по умолчанию. Взято из *highlight-default*
" Группа «Normal» должна быть первой, т. к. это будут общие параметры CSS
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


" Общие переменные
let s:is_norm = 0
let s:old_val = {}

function MainColo2Css(colofls, bgr, outdir, fnt)
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
      if !has('gui_running')
	exe "normal \<Esc>"
	echoerr "Работа подключаемого модуля возможна только в графической оболочке (GUI)"
	return -1
      endif
" Сохраняем глобальные данные, которые будем изменять
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
" НАДО: наименование буфера как переменная
	exe 'autocmd BufWipeout ' s:NME_TMP_BUF ' call <SID>CleanUp(' s:old_val
	      \ ..') | delfunction <SID>CleanUp'
"	autocmd BufWipeout Tmp_Colo2CSS call<SID>CleanUp(s:old_val)
	      "\ | delfunction <SID>CleanUp
      augroup END
    else
      highlight clear Normal
      highlight clear
      syntax reset
      syntax clear
      execute('silent colorscheme ' .. l:clch)
    endif
    call s:HiGroups2Buf()
    if bufexists(s:NME_TMP_BUF)
      let l:cssentries = []
" При первом проходе цикла должны быть определены глобальные переменные
" значениями из группы «Normal». Также эта группа имеет некоторые отличия от
" других групп, которые надо учитывать
      let s:is_norm = 1
      for l:grpname in s:INIT_GRP
	call setpos('.', [0, 1, 1, 0])
	let l:fndlnr = search('^\<' ..l:grpname.. '\>', 'cW', line('$'))
	if l:fndlnr || (!l:fndlnr && s:is_norm)
	  let l:cssrule = s:HiGrpLn2CssRule(l:grpname, l:fndlnr)
	  if !empty(l:cssrule) && type(0) != type(l:cssrule)
	    call add(l:cssentries, l:cssrule)
	  endif
	endif
" Группа «Normal» может быть только одна, обнулим этот признак после первого (и
" всех последующих) проходов цикла
	let s:is_norm = 0
      endfor
      while getline(1) != ""
	let l:fndlnr = line('.')
	let l:grpname = s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
	if empty(l:grpname)
	  execute l:fndlnr 'delete'
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
" Бывает, что наименование цветовой схемы не задано.
	  if 0 <= stridx(l:coloschm, 'E121:')
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
	  \ .. '_' .. &bg .. '-' ..
"\ ПРАВЬ: Убери эту строку в финале.
	  \ strftime("%d%m%Y%H%M%S", localtime())
	  \ .. '.css'
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


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file MainColo2Css.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
