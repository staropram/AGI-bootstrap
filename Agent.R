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

		chat = function(msg) {
			if(self$config$trackTokens) {
				# every message we send would have to be
				# formatted correctly too, for us 
				# to track tokens, maybe just get the
				# AI to ask how many tokens
				#msg$tokens_used <- self$tokensUsed
				# XXX
			}
			response <- self$gptInterface$chat(msg)
			self$tokensUsed <- response$apiResponse$usage$total_tokens
			response
		}
	)
)
