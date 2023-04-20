command_end_agent_chat <- list(
  active = T,
  author = "human",
  usage = list(
	  action="end_agent_chat",
	  id="agent_id",
	  comment="Ends a conversation with a chatGPT agent."
	),
  f = function(args) {
	  # at the moment just leave the agent alive
	  # and inform the AI that the chat has ended
	  list(
        status=paste0('chat with "',args$id,'" ended')
	  )
  }
)
