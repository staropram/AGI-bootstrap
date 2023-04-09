command_list_commands <- list(
	active=T,
	author="human",
	usage='{"action":"list_commands","comment":"Lists ALL available commands."}',

	# add a list commands command
	f=function(args) {
		toJSON(commandHandler$commandList)
	},

	print=function(msg) {
		cat(red,"action: ",msg$action,reset,"\n")
		cat(blue,"comment: ",msg$comment,reset,"\n")
	}
)
