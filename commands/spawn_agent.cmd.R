command_spawn_agent <- list(
	active = T,
	author = "human",
	usage = list(
		action="spawn_agent",
		max_tokens="[0,4096]",
		comment="Spawns a chatGPT agent"
	),
	f = function(args) {
		agentManager$spawnAgent(args$max_tokens)
	}
)
