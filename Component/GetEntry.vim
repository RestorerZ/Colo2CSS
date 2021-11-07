






function s:GetEntry(bnr, lnr, colnr, offset, motion)
    let @e = ""
    if !setpos('.', [a:bnr, a:lnr, a:colnr, a:offset])
	execute 'normal "ey' .. a:motion
    endif
    return getreg('e')
endfunction

