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
			agent$id <- paste0("a",self$agentIDSeq)
			self$addAgent(agent)
		},

		spawnHuman = function() {
			print("A")
			id <- paste0("h",self$agentIDSeq)
			agent <- HumanAgent$new(id)
			self$addAgent(agent)
		},

		spawnAgent = function(max_tokens) {
			# can override agent options here if needed
			# just chatgpt agent for now
			conf <- self$config
			conf$chatType <- "chatgpt"
			conf$runtimeDirPrefix <- "runtime"
			conf$continuous <- T
			conf$cleanWorkingDir <- F
			conf$chat_gpt$max_tokens <- max_tokens
			agent <- Agent$new(conf,paste0("a",self$agentIDSeq))
			self$addAgent(agent)
			agent$id
		},

		chatWithAgent = function(id,msg) {
			if(! as.character(id) %in% names(self$agents)) {
				return(NULL)
			}
			self$agents[[id]]$chat(msg)
		},

		newAgent = function() {
			agent <- Agent$new(self$config,paste0("a",self$agentIDSeq))
			self$addAgent(agent)
			agent
		},

		# sets the message context back to nothing
		# so the agent can be reused
		resetMessages = function(id) {
			self$agents[[id]]$resetMessages()
		},

		# deletes the specified agent
		deleteAgent = function(id) {
			self$agents[id] <- NULL
			self$agentCount <- self$agentCount - 1
		},

		getTokensUsed = function(id) {
			if(! id %in% names(self$agents)) {
				return('{"error":"invalid agent id"}')
			}
			tokens <- self$agents[[id]]$tokensUsed
			paste0('{"tokens_used":"',tokens,'"}')
		}

	)
)
