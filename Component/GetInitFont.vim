
function GetInitFont()
    let @t = ''
    let @t = getfontname()
    if empty(@t)
	let @t = &guifont
	if !empty(@t)
" Шаблон поиска не очень хороший
	    let l:com = match(@t, '\w,')
	    if 0 < l:com
		let @t = strpart(@t, 0, l:com)
	    endif
	endif
    endif
    return getreg('t')
endfunction
