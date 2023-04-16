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

		syncChatOpenAI = function(agent,msg) {
			encodedMsg <- commandHandler$encodeCommand(msg)
			agent$appendMessage("user",encodedMsg)
			completion <- create_chat_completion(
			  model = config$chatgpt$model,
			  messages = agent$messages,
			  max_tokens = config$chatgpt$max_tokens,
			  temperature = config$chatgpt$temperature 
			)
			response <- completion$choices$message.content
			agent$appendMessage("assistant",response)
			agent$lastChatPartner <- msg$from
			response
		},

		syncChatFakeAI = function(agent,msg) {
			Sys.sleep(config$fakegpt$artificialDelaySecs)
			encodedMsg <- commandHandler$encodeCommand(msg)
			self$fakeAI$syncChat(encodedMsg)
		},

		chatOpenAI = function(agent,msg) {
			encodedMsg <- commandHandler$encodeCommand(msg)
			agent$appendMessage("user",encodedMsg)
			completion <- future({create_chat_completion(
			  model = config$chatgpt$model,
			  messages = agent$messages,
			  max_tokens = config$chatgpt$max_tokens,
			  temperature = config$chatgpt$temperature 
			)})
			completion %...>% (function(r) {
				response <- r$choices$message.content
				agent$appendMessage("assistant",response)
				commandHandler$handleCommand(response,agent)
				agent$lastChatPartner <- msg$from
			})
			NULL
		},

		chatFakeAI = function(agent,msg) {
			Sys.sleep(config$fakegpt$artificialDelaySecs)
			encodedMsg <- commandHandler$encodeCommand(msg)
			self$fakeAI$chat(encodedMsg,agent)
			NULL
		},

		syncChat = function(msg) {
			f <- switch(self$type,
				"chatgpt" = self$syncChatOpenAI,
				"fakegpt" = self$syncChatFakeAI
			)
			f(self$agent,msg)
		},

		chat = function(msg) {
			f <- switch(self$type,
				"chatgpt" = self$chatOpenAI,
				"fakegpt" = self$chatFakeAI
			)
			f(self$agent,msg)
			
			# note that there is no response
			# as the chat is handled asyncronously
			# and when the result is obtained, handle
			# command is then called
			return(NULL)
		}
	)
)
