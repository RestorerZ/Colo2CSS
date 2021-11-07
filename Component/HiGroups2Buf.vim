
" Честно подсмотрено в hitest.vim
function HiGroups2Buf()
" сохраняем действующие значения параметров
"    let s:hidden_old      = &hidden
"    let s:lazyredraw_old  = &lazyredraw
"    let s:more_old        = &more
"    let s:report_old      = &report
"    let s:whichwrap_old   = &whichwrap
"    let s:shortmess_old   = &shortmess
"    let s:wrapscan_old    = &wrapscan
"    let s:spell_old       = &spell
"    let s:whichwprap_old  = &whichwrap
"    let s:register_a_old  = @h
"    let s:register_se_old = @/

" задаём необходимые нам значения параметров
    set hidden lazyredraw nomore report=99999 shortmess=aAoOsStTW nowrapscan
    set nospell whichwrap&

" Считываем в регистр "h вывод команды `highlight`
    redir @h
    silent highlight
    redir END

" Создаём новое окно если текущее окно содержит какой‐нибудь текст
" НАДО: в окончательном варианте надо это удалить, т. к. не потребуется и
"    сделано здесь для целей тестирования
"    if line("$") != 1 || getline(1) != ""
"	new
"    endif

" Создаём временный буфер
    edit Tmp_colo2css

" И устанавливаем для него необходимые локальные параметры textwidth=0 
    setlocal noautoindent noexpandtab formatoptions=""
    setlocal noswapfile
    setlocal buftype=nofile
    let &textwidth=&columns

" Помещаем в созданный буфер содержимое регистра "h
    put h

" Удалим те группы, которые не заданы в этой цветовой схеме
    silent! global/ cleared$/delete

" Также удаляем символы «xxx» в выводе команды `:highlight`
"    global/xxx /s///e
    %substitute/xxx //e

" Объединяем строки с наименованием группы и ссылкой на группу, если есть перенос
    silent! global/^\s*links to \w\+/.-1join

" Для ускорения поиска удаляем пустые строки
    silent! global/^\s*$/delete
    
"Обрабатывать будем только группы и аттрибуты для gui
"   global/\%[c]term=\w\+,\=\%[\w]\+\s/s///eg
"   global/\%[c]term\%(bg\|fg\|ul\)=\w\+\s/s///eg 
"
"   silent! global/\%[c]term=\w\+\s/s///eg

"    silent! global/cterm=\w\+\s/s///eg
    silent! %substitute/\<cterm=\w\+\s//e
"    silent! global/cterm=\w\+,\w\+\s/s///eg
    silent! %substitute/\<cterm=\w\+,\w\+\s//e
"    silent! global/term=\w\+\s/s///eg
    silent! %substitute/\<term=\w\+\s//e

"   silent! global/\%[c]term=\w\+,\w\+\s/s///eg

"    silent! global/term=\w\+,\w\+\s/s///eg
    silent! %substitute/\<term=\w\+,\w\+\s//e
"    silent! global/start=\w\+\s/s///e 
    silent! %substitute/\<start=\w\+\s//e 
"    silent! global/stop=\w\+\s/s///e 
    silent! %substitute/\<stop=\w\+\s//e 
"    silent! global/ctermfg=\w\+\s/s///e 
    silent! %substitute/\<ctermfg=\w\+\s//e 
"    silent! global/ctermbg=\w\+\s/s///e 
    silent! %substitute/\<ctermbg=\w\+\s//e 
"    silent! global/ctermul=\w\+\s/s///e 
    silent! %substitute/\<ctermul=\w\+\s//e 
endfunction

call HiGroups2Buf()

