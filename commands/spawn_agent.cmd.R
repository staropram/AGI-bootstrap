command_spawn_agent <- list(
  active = T,
  author = "human",
  usage = '{"action":"spawn_agent","id":"agent_id","max_tokens":"max_tokens","comment":"Spawns a chatGPT agent with the specified ID and specified params."}',
  f = function(args) {
	  agentManager$spawnAgent(args$id,args$max_tokens)
  },

  # print the message
  printMsg = function(msg) {
		print_action(msg$action)
		print_comment(msg$comment)
  }
)