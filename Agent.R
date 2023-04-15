source('GPTInterface.R')
Agent <- R6Class(
	"Agent",
	public = list(
		id = "",
		messages = list(),
		gptInterface = NULL,
		config = NULL,
		workingDir = "",
		tokensUsed = 0,
		lastChatPartner = NULL,

		initialize = function(config,id) {
			self$id <- id
			self$gptInterface <- GPTInterface$new(self,config)
			self$config <- config
			self$workingDir <- paste0(
				config$runtimeDirPrefix,"/",
				config$aiName
			)
			self
		},

		appendMessage = function(role,msg) {
			self$messages <- c(self$messages,list(list(
				"role" =role,"content"=msg
			)))
		},

		resetMessages = function() {
			self$messages <- list()
		},

		chat = function(cmdMsg) {
			#encodedMsg <- commandHandler$encodeCommand(cmdMsg)
			response <- self$gptInterface$chat(cmdMsg)
			#print(paste0("Agent responding: ",response))
			response
		}
	)
)
