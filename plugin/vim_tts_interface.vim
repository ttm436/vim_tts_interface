let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:temp = s:path . '/../temp/'

function! GetTTSCode()
	let l:_ = system("nc -ld 127.0.0.1 39998 > " . s:temp . "__message__ &")
	let l:_ = system("echo '{\"messageID\":0}' | nc -w3 127.0.0.1 39999") 
	let l:_ = system("perl message_parse.pl load " . s:temp)
	let l:scripts = s:temp . "scripts/*.lua"
	execute("e " . l:scripts)
endfunction

function! PushTTSCode()
	let l:_ = system("perl message_parse.pl save " . s:temp)
	let l:_ = system("nc -w3 127.0.0.1 39999 < " . s:temp . "__message__")
endfunction

	

