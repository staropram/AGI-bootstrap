command_exit <- list(
	active=T,
	author="human",
	usage=list(
		action="exit",
		comment="Saves the state and exits the top level program. Do not use to exit an agent chat."
	),
	f=function(args) {
		"exit"
	}
)
