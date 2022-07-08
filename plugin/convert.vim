let s:save_cpo = &cpoptions
set cpoptions&vim

command! -nargs=0 -range CNV call convert#CNV_Start(<range>, <line1>, <line2>)

let &cpoptions = s:save_cpo
unlet s:save_cpo
