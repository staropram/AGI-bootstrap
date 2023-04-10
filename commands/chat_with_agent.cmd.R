command_chat_with_agent <- list(
	active = T,
	author = "human",
	usage = '{"action":"chat_with_agent","id":"agent_id","msg":"message","comment":"Send message to a chatGPT agent with id=agent_id, including all previous messages in conversation. Returns the chatGPTs response."}',
	f = function(args) {
		response <- agentManager$chatWithAgent(args$id,args$msg)
		if(is.null(response)) {
			return('{"error":"invalid agent id","comment":"you need to spawn an agent first"}')
		}
		# extract the message
		response$apiResponse$choices$message.content[1]
	},

	# print the message
	printMsg = function(msg) {
		print_action(msg$action)
		print_param("id",msg$id)
		print_param("message",msg$msg)
		print_comment(msg$comment)
	}
)
