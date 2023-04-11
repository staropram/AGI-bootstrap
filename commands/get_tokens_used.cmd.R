command_get_tokens_used <- list(
  active = T,
  author = "human",
  usage = '{"action":"get_tokens_used","id":"agent_id","comment":"Number of tokens used by specified agent."}',
  f = function(args) {
	 agentManager$getTokensUsed(args$id)
  }
)
