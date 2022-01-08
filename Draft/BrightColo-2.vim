" BrightColo.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorers@users.sf.net>
" Last change:	05 Jan 2022
" Version:	1.0.4
" Description:	уменьшение или увеличение яркости (или насыщенности) цвета
"		decrease or increase the brightness (or saturation) of a color
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/








function s:Dec2Hex(str)
" Так, конечно, делать не надо. Такие читы до добра не доводят!
"   let l:hex=printf("%X", a:str)
"   return l:hex
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



function! BrightColo(hexcolo, corr, lord)
    echo 'a000 ' a:000
    echo 'a0 ' a:0
    let l:hexcolo = ''
    let l:rr = str2nr(a:hexcolo[0:1], 16)
    let l:gg = str2nr(a:hexcolo[2:3], 16)
    let l:bb = str2nr(a:hexcolo[4:5], 16)
    let l:corr = str2float(a:corr)
    let l:Yr = 0.299000 * l:rr
    echo 'lYr ' l:Yr
    let l:Yg = 0.587000 * l:gg
    echo 'lYg ' l:Yg
    let l:Yb = 0.114000 * l:bb
    echo 'lYb ' l:Yb
    let l:Yrgb = l:Yr+l:Yg+l:Yb
    if 'l' ==? a:lord
"	let l:Yr -= l:corr
"    echo 'lYr ' l:Yr
"	let l:Yg -= l:corr
"    echo 'lYg ' l:Yg
"	let l:Yb -= l:corr
"    echo 'lYb ' l:Yb
    let l:Yrgb -= l:corr
    elseif 'd' ==? a:lord
"	let l:Yr += l:corr
"    echo 'lYr ' l:Yr
"	let l:Yg += l:corr
"    echo 'lYg ' l:Yg
"	let l:Yb += l:corr
"    echo 'lYb ' l:Yb
    let l:Yrgb += l:corr
    endif
    let l:rr = l:Yrgb + 1.4075
    let l:gg = l:Yrgb - 0.3455
    let l:bb = l:Yrgb + 1.7790
"    let l:Yr = (0 > l:Yr ? 0 : 255 < l:Yr ? 255 : l:Yr)
"    echo 'lYr ' l:Yr
"    let l:Yg = (0 > l:Yg ? 0 : 255 < l:Yg ? 255 : l:Yg)
"    echo 'lYg ' l:Yg
"    let l:Yb = (0 > l:Yb ? 0 : 255 < l:Yb ? 255 : l:Yb)
"    echo 'lYb ' l:Yb
    let @h = ''
    let @h = s:Dec2Hex(l:Yr)
    let @h = (2 != len(@h) ? 0..@h : @h)
    let l:hexcolo ..= @h
    let @h = ''
    let @h = s:Dec2Hex(l:Yg)
    let @h = (2 != len(@h) ? 0..@h : @h)
    let l:hexcolo ..= @h
    let @h = ''
    let @h = s:Dec2Hex(l:Yb)
    let @h = (2 != len(@h) ? 0..@h : @h)
    let l:hexcolo ..= @h
    return l:hexcolo
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file BrightColo.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
