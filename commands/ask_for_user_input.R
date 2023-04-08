command_ask_for_user_input <- list(
	active=T,
	author="human",
	usage='{"action":"ask_for_user_input","query":"your query"} use this if you need something from me such as an API key or if you need something from me you cannot do. You should only use this when you have exhausted all other options.',
	f=function(args) {
		print(args$query)
		readline()
	}
)
