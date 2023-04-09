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
			self$agentIDSeq <- self$agentIDSeq + 1
			self$agentCount <- self$agentCount + 1
		},

		# if we are restoring the agent we need to
		# make sure the agents ID matches what the
		# manager expects
		restoreAgent = function(agent) {
			browser()
			agent$id <- paste0("a",self$agentIDSeq)
			self$addAgent(agent)
		},

		newAgent = function() {
			agent <- Agent$new(self$config,self$agentIDSeq)
			self$addAgent(agent)
			agent
		}

	)
)
