HumanAgent <- R6Class(
	"HumanAgent",
	public = list(
		id="",

		initialize = function(id) {
			self$id = id
			self
		},

		chatWithAgent = function(id,msg) {
			cmdMsg <- list(
				from=self$id,
				to=id,
				action="chat_with_agent",
				msg=msg
			)
			commandHandler$handleCommand(
				commandHandler$encodeCommand(cmdMsg)
			)
		},

		# this is called by other agents when they
		# want to chat with us, also by default
		# any message that doesn't make sense gets
		# sent to us
		chat = function(msg) {
			print(paste0("received msg: ",msg))
		}

	)
)
