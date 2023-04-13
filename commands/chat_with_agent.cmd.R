command_chat_with_agent <- list(
	active = T,
	author = "human",

	usage = list(
		action="chat_with_agent",
		from="src_id",
		to="dst_id",
		msg="message"
	),
										 
	description="Send message from agent with src_id to agent with dst_id. Returns the response.",

	f = function(cmdMsg) {
		# send the message to the agent
		response <- agentManager$chatWithAgent(cmdMsg)
		browser()
		if(is.null(response)) {
			# need to encode
			return('{"error":"invalid agent id","comment":"you need to spawn an agent first"}')
		}
		# extract the message
		response$apiResponse$choices$message.content[1]
	}
)
