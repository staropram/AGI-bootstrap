HumanAgent <- R6Class(
	"HumanAgent",
	public = list(
		id="",

		initialize = function(id) {
			self$id = id
			self
		},

		chatWithAgent = function(id,msg) {
			msg=commandHandler$encodeCommand(list(
				from=self$id,
				to=id,
				action="chat",
				msg=msg
			))
			commandHandler$handleCommand(msg,self)
		},

		# called by the command handler to ask
		# permission if it can execute the command
		askPermission = function(msg) {

			a <- "z"
			response <- list(
				choice="c"
			)
			# any message originating from C0 or h0
			# does not require permission, 
			# we already validated the sender earlier
			print("THIS")
			browser()
			if(msg$msg$from %in% c("C0","h0")) {
				return(response)
			}

			while(a!="i") {
				cat("c-continue, i-interact, d-debug, q-quit: ")
				flush.console()
				a <- readline()
				if(a=="i") {
					response$msg <- readline("Respond: ")
					response$choice <- "i"
					break
				} else if(a=="d") {
					browser()
				} else if(a=="q") {
					response$choice <- "q"
					break
				} else if(a=="c") {
					response$choice <- "c"
					break
				}
			}
			response
		},

		# gets user input
		getInput = function(msg) {
			a <- "z"
			while(a!="i") {
				a <- readline("i-interact, d-debug, q-quit: ")
				if(a=="i") {
					return(readline("Respond: "))
				} else if(a=="d") {
					browser()
				} else if(a=="q") {
					return(NULL)
				} 
			}
		},

		# this is called by other agents when they
		# want to chat with us, also by default
		# any message that doesn't make sense gets
		# sent to us
		chat = function(msg) {
			# get the response from the user
			# pass the message incase the user wants
			# it for debug info
			response <- self$getInput(msg)
			# if the user quits it returns a null response
			# if we stop chatting with the agent, our
			# conversation cannot continue so this is like
			# a quit
			#if(!is.null(response)) {
			#	self$chatWithAgent(msg$from,response)
			#}
			if(is.null(response)) {
				return(commandHandler$encodeCommand(list(
					from="h0",
					action="exit",
					comment="user requested exit"
				)))
			}

			commandHandler$encodeCommand(list(
				from="h0",
				to=msg$from,
				action="chat",
				msg=response
			))
		}
	)
)
