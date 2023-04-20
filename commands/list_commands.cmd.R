command_list_commands <- list(
	active=T,
	author="human",
	usage=list(
		action="list_commands",
		comment="Lists ALL available commands."
	),

	# add a list commands command
	f=function(args) {
		commandHandler$commandList
	}
)
