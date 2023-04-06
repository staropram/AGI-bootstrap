command_write_file <- list(
	usage='{"action":"write_file","fn":"filename","content":"filecontents"} where filename is your filename and filecontents are the contents you wish to write',
	f=function(args) {
		write(args$content,file=args$filename)
	}
)
