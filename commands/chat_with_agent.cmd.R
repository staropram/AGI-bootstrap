command_chat_with_agent <- list(
	active = T,
	author = "human",
	usage = '{"action":"chat_with_agent","to_id":"agent_id",from_id="from","msg":"message","comment":"Send message to a human or chatGPT agent with id=agent_id, including all previous messages in conversation. Returns the response."}',
	f = function(args) {
		response <- agentManager$chatWithAgent(args$id,args$msg)
		if(is.null(response)) {
			return('{"error":"invalid agent id","comment":"you need to spawn an agent first"}')
		}
		# extract the message
		response$apiResponse$choices$message.content[1]
	}
)
