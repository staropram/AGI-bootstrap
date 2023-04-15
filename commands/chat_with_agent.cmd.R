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
		#print(paste0("command responding"))
		agentManager$chatWithAgent(cmdMsg)
	}
)
