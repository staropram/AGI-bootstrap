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
		print_action(msg$action)
		print_param("fn",msg$fn)
		print_param("content",msg$content)
		print_comment(msg$comment)
	}
)
