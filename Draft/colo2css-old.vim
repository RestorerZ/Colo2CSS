" colo2css.vim
" Maintainer:	Restorer
" Last change:	13 jul 21
" Version:	0.0.1a
" Description:	converting colorscheme file to CSS file




" Поиск строки, содержащей заданный шаблон
function s:Srch_ln(pat, flgs, stpln, tout, skip)
    return search(a:pat, a:flgs, a:stpln, a:tout, a:skip)
endfunction

function s:Mtch_chk(exp, pat, strt, cnt)
    return matchend(a:exp, a:pat, a:strt, a:cnt)
endfunction

function s:Srch_grpname(grpname)
    normal gg
    let s:srch_pat = "^\\<" .. a:grpname .. "\\>"
    let s:srch_flgs = "Wn"
    return s:Srch_ln(s:srch_pat, s:srch_flgs, s:srch_stpln, s:srch_tout, s:srch_skip)
endfunction

function s:Getgrpname(bnum, lnum, colnum, grpname)
    let @h = ""
"    echo "bnum " a:bnum
"    echo "lnum " a:lnum
"    echo "colnum " a:colnum
"    echo "grpname " a:grpname
    call setpos('.', [a:bnum, a:lnum, a:colnum, 0])
    normal "hyiw
    return getreg('h')
endfunction

function s:Grpname2cssclass(grpnme)
    echomsg "iam 2cssclass"
    let @h = ""
    let @h = ', ' .. '.' .. a:grpnme
    echo "getreg-h" getreg('h')
    return getreg('h')
endfunction

function s:Srch_lnkgrp(togrpname)
    echomsg "iam s:Srch_lnkgrp"
    let @H = ""
"    echomsg "@H " getreg('H')
    normal gg
    let s:srch_pat = "links to\\s\\+" .. a:togrpname .. "$"
    let s:srch_flgs = "W"
    let l:lnum = 1
    let l:lnkgrpnm = ""
    while l:lnum
	let l:srch_lnr = s:Srch_ln(s:srch_pat, s:srch_flgs, s:srch_stpln, s:srch_tout, s:srch_skip)
"	echo "l:srch_lnr " l:srch_lnr
	if l:srch_lnr
"	echo "l:srch_lnr " l:srch_lnr
	    let l:grpnm = s:Getgrpname(0, l:srch_lnr, 1, 0)
"	echoerr "l:grpnm " l:grpnm
"	    call setpos('.', [0, l:srch_lnr, 1, 0])
"	    execute "let " .. l:lnkgrpname .. " = " .. l:lnkgrpname .. call (matchstr(line('.'), '\a\+'), "")
"	    normal "hyiw
"	    let l:contreg = getreg('h')
"	    let l:lnkgrpname = l:lnkgrpname .. ', ' .. '.' .. l:contreg 
	    if "" != l:grpnm
    echomsg "iam go 2cssclass"
		let l:lnkgrpnm = s:Grpname2cssclass(l:grpnm)
	echomsg "l:lnkgrpnm " l:lnkgrpnm
		if "" != l:lnkgrpnm
		    let @H .= l:lnkgrpnm
    echoerr "@H " getreg('H')
"		    delete
		    execute l:srch_lnr "delete"
		endif
	    endif
	endif
	let lnum = l:srch_lnr
    endwhile
"    return l:lnkgrpnm
    return getreg('H')
endfunction

" function s:Srch_hiagr(nrstr)
    " let l:line = getline(a:nrstr)
"    for item in s:hiarg
"	let s:srch_pat = item .. '='
"	let l:endmatch = s:Mtch_chk(l:line, s:srch_pat)
"	if l:endmatch => 0
"	    call setpos('.', [0, a:nrstr, l:endmatc, 0])
"	    if 0 == index(s:hiarg, item) || 4 == index(s:hiarg, item)
"		let srch_pat = "\\(\\a\\+,\\=\\)\\+"
"		let l:hival = s:Mtch_chk(str, l:line, s:srch_pat)
"	    elseif 
"	endif
"endfunction

function s:Get_hiagr(nrstr, hiitem)
    let l:line = getline(a:nrstr)
	let l:srch_pat = a:hiitem .. '='
	if s:Mtch_chk(l:line, l:srch_pat) => 0
	    call setpos('.', [0, a:nrstr, l:endmatc, 0])
	    if 0 == index(s:hiarg, a:hiitem) || 4 == index(s:hiarg, a:hiitem)
"		let srch_pat = "\\(\\a\\+,\\=\\)\\+"
"		let l:hival = s:Mtch_chk(str, l:line, s:srch_pat)
"	    elseif 
"	endif
"endfunction

" Честно подсмотрено в hitest.vim
function s:HiGroups2Buf()
    " сохраняем действующие значения параметров
    let s:hidden_old      = &hidden
    let s:lazyredraw_old  = &lazyredraw
    let s:more_old        = &more
    let s:report_old      = &report
    let s:whichwrap_old   = &whichwrap
    let s:shortmess_old   = &shortmess
    let s:wrapscan_old    = &wrapscan
    let s:spell_old       = &spell
    let s:whichwprap_old  = &whichwrap
    let s:register_a_old  = @h
    let s:register_se_old = @/

    " задаём необходимые нам значения параметров
    set hidden lazyredraw nomore report=99999 shortmess=aAoOsStTW nowrapscan
    set nospell whichwrap&

    " Считываем в регистр «h» вывод команды `highlight`
    redir @h
    silent highlight
    redir END

    " Создаём новое окно если текущее окно содержит какой‐нибудь текст
    " НАДО: в окончательном варианте надо это удалить, т. к. не потребуется и
"    сделано здесь для целей тестирования
    if line("$") != 1 || getline(1) != ""
	new
    endif

    " Создаём временный буфер
    edit Tmp_colo2css

    " И устанавливаем для него необходимые локальные параметры textwidth=0 
    setlocal noautoindent noexpandtab formatoptions="" noswapfile
    setlocal buftype=nofile
    let &textwidth=&columns

    " Помещаем в созданный буфер содержимое регистра «h»
    put h

    " Ещё удалим те группы, которые не заданы в этой цветовой схеме
    silent! global/ cleared$/delete

    " Также удаляем символы «xxx» в выводе команды `:highlight`
    global/xxx /s///e

    " Объединяем строки с наименованием группы и ссылкой на группу,
    " если есть перенос
    "% substitute /^\(\w\+\)\n\s*\(links to.*\)/\1\t\2/e
    global/^\s*links to .\+/.-1normal J

    " Для ускорения поиска удаляем пустые строки
    global/^\s*$/ delete


    let s:srch_pat = ""
    let s:srch_flgs = ""
    let s:srch_stpln = ""
    let s:srch_tout = ""
    let s:srch_skip = ""
    let s:cssrule = ""
    let s:cssrule_sel = ""
    let s:srch_lnr = 0
    let s:higrp_lnr = 0
    let s:cssrule_dec = ""
endfunction










" Группы подсветки, используемые по умолчанию. Взято из *highlight-default*
" Группа «Normal» должна быть первой, т. к. это будут начальные настройки CSS
" let s:defcolo = ['Normal', 'ColorColumn', 'Conceal', 'Cursor', 'lCursor', 'CursorIM', 'CursorColumn', 'CursorLine', 'Directory', 'DiffAdd', 'DiffChange', 'DiffDelete', 'DiffText', 'EndOfBuffer', 'ErrorMsg', 'VertSplit', 'Folded', 'FoldColumn', 'SignColumn', 'IncSearch', 'LineNr', 'LineNrAbove', 'LineNrBelow', 'CursorLineNr', 'MatchParen', 'ModeMsg', 'MoreMsg', 'NonText', 'Pmenu', 'PmenuSel', 'PmenuSbar', 'PmenuThumb', 'Question', 'QuickFixLine', 'Search', 'SpecialKey', 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare', 'StatusLine', 'StatusLineNC', 'StatusLineTerm', 'StatusLineTermNC', 'TabLine', 'TabLineFill', 'TabLineSel', 'Terminal', 'Title', 'Visual', 'VisualNOS', 'WarningMsg', 'WildMenu']


let s:specattr = ['bold', 'underline', 'undercurl', 'strikethrough', 'reverse', 'inverse', 'italic', 'standout', 'nocombine', 'NONE',]

let s:hiarg = ['gui', 'font', 'guifg', 'guibg', 'guisp']

 let s:defcolo = ['Normal', 'ColorColumn', ]

" Буфер и файл наименование
"let s:cssname = g:colors_name .. '.css' 

"let s:bnr=bufadd(s:cssname)

"call bufload("s:bnr")

"execute "buffer" s:cssname


" Get_grpname_as_cssclass

while line("$") != 1 || getline(1) != ""
    for item in s:defcolo
" Поиск наименования группы подсветки
	let s:srch_lnr = s:Srch_grpname(item)
	echo "s:srch_lnr " s:srch_lnr
	if s:srch_lnr
	    let s:higrp_lnr = s:srch_lnr
	    echo "s:higrp_lnr " s:higrp_lnr
	    let s:cssrule_sel = '.' .. item
	    echo "s:cssrule_sel " s:cssrule_sel
	    let s:cssrule = s:cssrule_sel
	    echo "s:cssrule " s:cssrule
" Поиск наименований групп, ссылающихся на эту групп
	    let s:cssrule_sel = s:Srch_lnkgrp(item)
	    echo "s:cssrule_sel " s:cssrule_sel
	    if "" != s:cssrule_sel
		let s:cssrule = s:cssrule .. s:cssrule_sel
		echo "s:cssrule " s:cssrule
	    endif
"	    let s:cssrule_bdef = s:Srhc
	    echo "s:cssrule" s:cssrule
	    let s:cssrule = ""
	    echo s:cssrule
	endif
    endfor
    break
endwhile

" vim: tw=80:ft=vim:fenc=utf-8:ts=8:sw=4:noet
