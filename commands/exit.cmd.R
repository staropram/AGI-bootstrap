command_exit <- list(
	active=T,
	author="human",
	usage='{"action":"exit","comment":"Saves the state and exits the top level program. Do not use to exit an agent chat."}',
	f=function(args) {
		"exit"
	},

	# print the message
	printMsg=function(msg) {
		print_action(msg$action)
		print_comment(msg$comment)
	}
)
