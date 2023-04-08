AgentManager <- R6Class(
	"AgentManager",
	public = list(
		agents = list(),
		agentCount = 0,
		agentIDSeq = 0,
		config = NULL,

		initialize = function(config) {
			self$config <- config
		},

		addAgent = function(agent) {
			self$agents[[agent$id]] <- agent 
			#c(self$agents,list(id=agent))
		},

		newAgent = function() {
			agent <- Agent$new(self$config,self$agentIDSeq)
			self$agentIDSeq <- self$agentIDSeq + 1
			self$agentCount <- self$agentCount + 1
			self$addAgent(agent)
			agent
		}

	)
)
