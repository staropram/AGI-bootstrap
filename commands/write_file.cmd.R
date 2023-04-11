command_write_file <- list(
	active=T,
	author="human",
	usage='{"action":"write_file","fn":"filename","content":"filecontents","comment":"Writes filecontents to the specified file"}',
	f=function(args) {
		writeLines(args$content,args$fn)
		'{"status":"ok"}'
	}
)
