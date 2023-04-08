source("FakeAI.R")
GPTInterface <- R6Class(
	"GPTInterface",
	public = list(
		type = "",
		fakeAI = NULL,
		agent = NULL,
		config = NULL,

		initialize = function(agent,config) {
			self$agent <- agent
			self$type <- config$chatType
			self$config <- config
			if(self$type=="fakegpt") {
				self$fakeAI <- FakeAI$new(config)
			}
		},

		chatOpenAI = function(agent,msg) {
			agent$appendMessage("user",msg)
			completion <- create_chat_completion(
			  model = config$chatgpt$model,
			  messages = agent$messages,
			  max_tokens = config$chatgpt$max_tokens
			)
			agent$appendMessage("assistant",completion$choices$message.content)
			completion
		},

		chatFakeAI = function(msg) {
			self$fakeAI$chat(msg)
		},

		chat = function(msg) {
			f <- switch(self$type,
				"chatgpt" = self$chatOpenAI,
				"fakegpt" = self$chatFakeAI
			)
			apiResponse <- f(msg)
			list(
				apiResponse = apiResponse,
				msg=switch(self$type,
					"chatgpt" = apiResponse$choices$message.content,
					"fakegpt" = apiResponse
				)
			)
		}
	)
)
