command_exit <- list(
	active=T,
	author="human",
	usage='{"action":"exit","comment":"Saves the state and exits the dialog."}',
	f=function(args) {
		"exit"
	},

	# print the message
	printMsg=function(msg) {
		cat(paste0(red,"action: ",msg$action),reset,"\n")
		cat(paste0(blue,"comment: ",msg$comment),reset,"\n")
	}
)
