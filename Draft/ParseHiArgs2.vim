function ParseHiArgs(lnum)
    let l:str = getline(a:lnum)
    for l:hiarg in s:hi_args
	let @s = ""
