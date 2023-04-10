command_end_agent_chat <- list(
  active = T,
  author = "human",
  usage = '{"action":"end_agent_chat","id":"agent_id","comment":"Ends a conversation with a chatGPT agent."}',
  f = function(args) {
	  # at the moment just leave the agent alive
	  # and inform the AI that the chat has ended
     paste0('{"status":"chat with \"',args$id,'\" ended"}')
  },

  # print the message
  printMsg = function(msg) {
		print_action(msg$action)
		print_comment(msg$comment)
  }
)
