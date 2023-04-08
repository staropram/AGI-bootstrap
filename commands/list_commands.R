command_list_commands <- list(
	active=T,
	author="human",
	usage='{"action":"list_commands"} Lists ALL available commands.',

	# add a list commands command
	f=function(args) {
		toJSON(commandHandler$commandList)
	}
)
