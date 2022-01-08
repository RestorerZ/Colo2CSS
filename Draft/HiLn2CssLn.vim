






function HiLn2CssLn(grpname)
    if !empty(a:grpname)
	let l:fndlnr = ''
	let l:cssrule = []
	let l:csssel = s:HiGrpNm2CssSel(a:grpname)
	if !empty(l:csssel) && type(0) != type(l:csssel)
	    call insert(l:cssrule, l:csssel)
	    call setpos('.', [0,1,1,0])
	    let l:fndlnr = search('^\<' .. a:grpname .. '\>', 'cW', line('$'))
	    if 0 < l:fndlnr
		let l:hiattr = s:ParseHiArgs(l:fndlnr)
" Всё одно удаляем строку с этой группой, даже если мы не смогли получить её
" свойства, но только если она не ссылается на другие группы
		call deletebufline('Tmp_colo2css', l:fndlnr)
		if !empty(l:hiattr) && type(0) != type(l:hiattr)
		    let l:cssdecl = s:HiAttr2CssDecl(l:hiattr)
		    if !empty(l:cssdecl) && type(0) != type(l:cssdecl)
			let l:cssrule += l:cssdecl
		    endif
		endif
	    endif
	endif
	return l:cssrule
    endif
    return -1
endfunction

