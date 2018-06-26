let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:message_parse = s:path . '/../message_parse.pl'

function! GetTTSCode()
	let l:files = system("perl " . s:message_parse . " load")
	execute("e " . l:files)

endfunction

function! PushTTSCode()
	let l:_ = system("perl " . s:message_parse . " save")
endfunction

	

