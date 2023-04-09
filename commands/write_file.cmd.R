command_write_file <- list(
	active=T,
	author="human",
	usage='{"action":"write_file","fn":"filename","content":"filecontents","comment":"Writes filecontents to the specified file"}',
	f=function(args) {
		writeLines(args$content,args$fn)
		'{"status":"ok"}'
	},

	# print the message
	printMsg=function(msg) {
		cat(red,paste0("action: ",msg$action),reset,"\n")
		cat(green,paste0("fn: ",msg$fn),reset,"\n")
		cat(green,paste0("content: ",msg$content),reset,"\n")
		cat(green,paste0("comment: ",msg$comment),reset,"\n")
	}
)
