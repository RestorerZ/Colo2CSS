function Dec2Hex(str)
" Так, конечно, делать не надо. Такие читы до добра не доводят!
"   let l:hex=printf("%X", a:str)
"   return l:hex
    let l:hexdig=[0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F']
    let l:hex = ''
    let l:num=str2nr(a:str, 10)
    if 0 == l:num
	return 0 .. l:num
    else
	while l:num
	    let l:hex=l:hexdig[l:num%16] .. l:hex
	    let l:num/=16
	endwhile
    endif
    return l:hex
endfunction

