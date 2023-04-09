command_write_file <- list(
	active=T,
	author="human",
	usage='{"action":"write_file","fn":"filename","content":"filecontents","comment":"Writes filecontents to the specified file"}',
	f=function(args) {
		#f <- file(args$fn, "w")
		writeLines(args$content,args$fn)
		#close(f)
		"SUCCESS"
	}
)
