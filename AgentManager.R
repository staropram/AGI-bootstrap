AgentManager <- R6Class(
	"AgentManager",
	public = list(
		agents = list(),
		agentCount = 0,
		agentIDSeq = 0,
		# i don't know if we will ever have more
		# than one human
		humanCount = 0,
		humanIDSeq = 0,
		primaryHuman = NULL,
		config = NULL,

		initialize = function(config) {
			self$config <- config
		},

		addAgent = function(agent) {
			self$agents[[agent$id]] <- agent 
			self$agentIDSeq <- self$agentIDSeq + 1
			self$agentCount <- self$agentCount + 1
			agent
		},

		# if we are restoring the agent we need to
		# make sure the agents ID matches what the
		# manager expects
		restoreAgent = function(agent) {
			agent$id <- paste0("a",self$agentIDSeq)
			self$addAgent(agent)
		},

		spawnHuman = function() {
			id <- paste0("h",self$humanIDSeq)
			human <- HumanAgent$new(id)
			self$agents[[human$id]] <- human
			if(self$humanCount==0) {
				self$primaryHuman <- human
			}
			self$humanIDSeq <- self$humanIDSeq + 1
			self$humanCount <- self$humanCount + 1
			human
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

		chatWithAgent = function(msg) {
			# we have checked this anyway
			agent <- self$agents[[msg$to]]
			# keep track of who we were last talking to
			agent$chat(msg)
		},

		syncChat = function(msg) {
			# this will chat without using a subprocess
			agent <- self$agents[[msg$to]]
			agent$syncChat(msg)
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
				return(list(
					error="Invalid agent ID"
				))
			}
			tokens <- self$agents[[id]]$tokensUsed
			list(
				tokens_used=tokens
			)
		}

	)
)
