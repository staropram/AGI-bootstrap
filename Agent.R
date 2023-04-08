source('GPTInterface.R')
Agent <- R6Class(
	"Agent",
	public = list(
		id = "",
		messages = list(),
		gptInterface = NULL,
		config = NULL,

		initialize = function(config,id) {
			self$id <- paste0("a",id)
			self$gptInterface <- GPTInterface$new(self,config)
			self$config <- config
		},

		appendMessage = function(role,msg) {
			self$messages <- c(self$messages,list(list(
				"role" =role,"content"=msg
			)))
		},

		chat = function(msg) {
			#self$appendMessage("user",msg)
			#print(self$messages)
			#completion <- create_chat_completion(
			  #model = "gpt-3.5-turbo",
			 # messages = self$messages,
			 # max_tokens = 1024
			#)
			#self$appendMessage("assistant",completion$choices$message.content)
			#completion
			self$gptInterface$chat(msg)
		}
	)
)
