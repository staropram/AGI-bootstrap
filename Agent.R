source('GPTInterface.R')
Agent <- R6Class(
	"Agent",
	public = list(
		id = "",
		messages = list(),
		gptInterface = NULL,
		config = NULL,
		workingDir = "",

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

		chat = function(msg) {
			self$gptInterface$chat(msg)
		}
	)
)
