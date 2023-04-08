Agent <- R6Class(
	"Agent",
	public = list(
		id = "",
		messages = list(),

		initialize = function(id) {
			self$id <- paste0("a",id)
		},

		appendMessage = function(role,msg) {
			self$messages <- c(self$messages,list(list(
				"role" =role,"content"=msg
			)))
		},

		chat = function(msg) {
			self$appendMessage("user",msg)
			print(self$messages)
			completion <- create_chat_completion(
			  model = "gpt-3.5-turbo",
			  messages = self$messages,
			  max_tokens = 1024,
			  n = 1,
			  stop = NULL,
			  temperature = 0.7
			)
			self$appendMessage("assistant",completion$choices$message.content)
			completion
		}
	)
)
