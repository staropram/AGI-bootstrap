command_ask_for_help <- list(
	usage='{"action":"ask_for_help","query":"your query"} use this if you need something from me such as an API key or if you need something from me you cannot do',
	f=function(args) {
		print(args$query)
		readline()
	}
)
