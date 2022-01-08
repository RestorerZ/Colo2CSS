" CleanUp.vim	vim:ts=8:sts=2:sw=2:noet:sta
" Maintainer:	Restorer, <restorer@mail2k.ru>
" Last change:	05 Jan 2022
" Version:	1.3.9
" Description:	удаление из памяти отработавших функций и переменных, и
"		восстановление ранее сохранённых данных
"		removal of expired functions and variables from memory, and
"		recover previously saved data
" URL:		https://github.com/RestorerZ/Colo2CSS
" Copyright:	© Restorer, 2022
" License:	MPL 2.0, http://mozilla.org/MPL/2.0/



function <SID>CleanUp(oldval)
  for [l:key, l:val] in items(a:oldval)
    exe 'let ' .. l:key .. ' = ' .. '"' .. l:val .. '"'
  endfor
  unlet! s:NOT_RGB s:WINSYS_COLO s:FNT_SIZE s:SPEC_ATTR s:HI_ARGS s:INIT_GRP
  unlet! s:NME_TMP_BUF s:is_norm s:bg_norm s:fg_norm s:old_val
  delfunction <SID>HiGroups2Buf
  delfunction <SID>GetEntry
  delfunction <SID>GetLnkGrp
  delfunction <SID>Dec2Hex
  delfunction <SID>ColoStr2ColoNum
  delfunction <SID>GetColor
"  delfunction colo2css#GetInitFont
  delfunction <SID>ParseFont
  delfunction <SID>ParseHiArgs
  delfunction <SID>HiAttr2CssDecl
  delfunction <SID>HiGrpNme2CssSel
  delfunction <SID>HiGrpLn2CssRule
  delfunction <SID>RGB2HSB
  delfunction <SID>HSB2RGB
  delfunction <SID>BrightColo
  au! colo2css
endfunction


" This Source Code Form is subject to the terms of the Mozilla
" Public License, v. 2.0. If a copy of the MPL was not distributed
" with this file, You can obtain one at http://mozilla.org/MPL/2.0/
" The Original Code is file CleanUp.vim, https://github.com/RestorerZ/Colo2CSS
" The Initial Developer of the Original Code is Pavel Vitalievich Z. (also Restorer)
" All Rights Reserved.
