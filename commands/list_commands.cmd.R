command_list_commands <- list(
	active=T,
	author="human",
	usage=list(
		from="from_id",
		to="to_id",
		action="list_commands",
		comment="Lists ALL available commands."
	),

	# add a list commands command
	f=function(args) {
		toJSON(commandHandler$commandList)
	}
)
