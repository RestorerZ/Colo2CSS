


function s:GetEntry(bnr, lnr, colnr, offset, motion)
    let @e = ''
    if !setpos('.', [a:bnr, a:lnr, a:colnr, a:offset])
	execute 'normal "ey' .. a:motion
    endif
    return getreg('e')
endfunction




function GetLnkGrp(grpname)
    if !empty(a:grpname)
"	let @l = ""
	if !cursor(1,1)
	    let l:srchpat = 'links to\s\+' .. a:grpname .. '$'
	    let l:srchflgs = 'W'
	    let l:lnkgrpnm = ""
	    let l:lnr = 1
	    while l:lnr
		let l:fndlnr = search(l:srchpat, l:srchflgs, line('$'))
		if l:fndlnr
		    let l:lnkgrpnm = s:GetEntry(0, l:fndlnr, 1, 0, 'iw')
		    if !empty(l:lnkgrpnm)
			let @L = ' ' .. l:lnkgrpnm 
		    endif
		    execute l:fndlnr'delete'
" Могут быть группы, которые ссылаются на эту группу, которая ссылается на
" на начальную группу
		    call GetLnkGrp(l:lnkgrpnm)
		endif
	    let l:lnr = l:fndlnr
	    endwhile
"	return split(getreg('L'))
"	let @l = ''
	return @L
	endif
    endif
    return -1
endfunction


