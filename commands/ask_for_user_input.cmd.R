command_ask_for_user_input <- list(
	active=T,
	author="human",
	usage='{"action":"ask_for_user_input","query":"your query","comment":"Use this if you need something that is impossible otherwise for you to do. You should only use this when you have exhausted all other options."}',
	f=function(args) {
		cat("AI asked: \"")
		print(args$query)
		cat("\"\n")
		readline("Please respond: ")
	}
)
