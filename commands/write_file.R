command_write_file <- list(
	active=T,
	author="human",
	usage='{"action":"write_file","fn":"filename","content":"filecontents"} where filename is your filename and filecontents are the contents you wish to write',
	f=function(args) {
		#f <- file(args$fn, "w")
		writeLines(args$content,args$fn)
		#close(f)
		"SUCCESS"
	}
)
