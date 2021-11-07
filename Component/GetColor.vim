






function s:GetColor(colo)
    if !empty(a:colo)
"	if '#' == strcharpart(a:colo, 0, 1)
	if '#' == a:colo[0:0]
	    return trim(a:colo)
	elseif 0 <= stridx(tolower(a:colo), 'bg') ||
		    \ 0 <= stridx(tolower(a:colo), 'background')
	    return 'bg'
	elseif 0 <= stridx(tolower(a:colo), 'fg') ||
		    \ 0 <= stridx(tolower(a:colo), 'foreground')
	    return 'fg'
	elseif 0 <= stridx(toupper(a:colo), 'NONE')
	    return 'NONE'
	elseif 0 <= match(a:colo, '\w\+')
	    let @c = ""
	    let @c = s:ColoStr2ColoNum(a:colo)
	    if !empty(@c) && 0 <= @c 
		return '#' .. @c
	    endif
	endif
    endif
    return -1
endfunction

