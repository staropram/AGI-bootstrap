source("MessageTranscoder.R")
# load the commands
CommandHandler <- R6Class(
	"CommandHandler",
	public = list(
		config = NULL,
		commands = NULL,
		commandList = NULL,
		commandNames = NULL,
		workingDir = "",
		commandFiles = NULL,
		commandEncoding = NULL,
		transcoders = list(),

		initialize = function(config) {
			self$config <- config
			self$workingDir <- paste0(
				config$runtimeDirPrefix,"/",
				config$aiName
			)
			self$commandEncoding = config$commandEncoding

			self$commandNames <- config$commands
			self$commandFiles <- paste0(self$commandNames,".cmd.R")

			# create directory if necessary
			if(!dir.exists(self$workingDir)) {
				dir.create(self$workingDir)
			}
			# clean the directory if asked to in the config
			if(config$cleanWorkingDir==T) {
				for(f in list.files(self$workingDir)) {
					file.remove(paste0(self$workingDir,"/",f))
				}
			}

			# copy the base commands into the runtime dir
			for(fn in self$commandFiles) {
				fromFN <- paste0("commands/",fn)
				toFN <- self$workingDir
				file.copy(fromFN,toFN,overwrite=T)
			}

			# load the commmands
			self$loadCommands()

			# load the command transcoders
			self$loadTranscoders()
		},

		loadCommands = function() {
			self$commands <- lapply(self$commandNames,function(cmdName) {
				fn <- paste0(cmdName,".cmd.R")
				source(paste0(self$workingDir,"/",fn))
				file_content <- get(paste0("command_",cmdName))
				sc <- list()
				sc[[cmdName]] <- file_content
				get(paste0("command_",cmdName))
			})
			names(self$commands) <- self$commandNames
			self$commandList <- lapply(self$commands,function(cmd) {
				cmd$usage 
			})
		},

		loadTranscoders = function() {
			for(fn in list.files("transcoders")) {
				# source file
				source(paste0("transcoders/",fn))
				
				# initialize
				constructor <- paste0(gsub("\\.R","",fn),"$new()")
				trans <- eval(str2expression(constructor))
				self$transcoders[[trans$name]] <- trans
			}
		},

		# determines if a message is valid or not
		# returns a list because we might want to
		# add additional things in here in the future
		validate = function(msg,agent) {
			notValid <- list(isValid=F,setFrom=F)
			isValid <- list(isValid=T,setFrom=F)
			if(is.null(msg)) {
				notValid$error <- "Null command"
				return(notValid)
			}
			if(is.null(msg$action)) {
				notValid$error <- "Missing action param"
				return(notValid)
			}
			# check action exists
			actionExists <- msg$action %in% self$commandNames
			if(!actionExists) {
				notValid$error <- paste0("Invalid action: \"",msg$action,"\"")
				return(notValid)
			}

			# check that the parameters defined for this
			# action are provided
			actionCmd <- self$commands[[msg$action]]
			paramsProvided <- names(msg)
			paramsRequired <- names(actionCmd$usage)
			paramsRequired <- paramsRequired[paramsRequired!="comment"]
			errorMsg <- NULL
			for(param in names(paramsRequired)) {
				if(!param %in% paramsProvided) {
					errorMsg <- paste0(errorMsg,"parameter \"",param,"\" missing ")
				}
			}
			if(!is.null(errorMsg)) {
				notValid$error <- errorMsg
				return(notValid)
			}

			# check that the message has a "from" field
			# this isn't mandatory because we can fill
			# this in here (only an agent wouldn't set it)
			if(is.null(msg$from)) {
				# we passed msg by value so we can't change
				# it so we add a flag to isValid so in
				# the event the rest of the validation
				# passes, we can check it in commandhandler
				# messy, should make msg an object
				isValid$setFrom <- T
			}

			# check src and destination for chat msg
			if(msg$action=="chat") {
				# the src id should match the sending agent
				# unless it's me h0 as I can impersonate
				if(msg$from!=agent$id & agent$id!="h0") {
					notValid$error <- paste0("impersonation: from id: \"",msg$from,"\" does not match sending agent id: \"",agent$id,"\"")
					return(notValid)
				}

				# check separately if someone is trying
				# to chat with the controller
				if(msg$to=="C0") {
					notValid$error <- "You cannot \"chat\" with C0, only send normal commands"
					return(notValid)
				}

				# finally check the "to" agent exists
				validToIDs <- names(agentManager$agents)
				if(! msg$to %in% validToIDs) {
					notValid$error <- paste0("to: \"",msg$to,"\" does not exist.")
					return(notValid)
				}
			}

			isValid
		},

		# this receives an encoded message from any agent
		# and must attempt to decode the message and
		# properly handle it
		handleCommand = function(rawMsg,agent,validate=T) {

			# attempt to decode the message
			cmdDecoded <- self$decodeCommand(rawMsg)
			# if we cannot decode
			if(!cmdDecoded$success) {
				# gpt3.5 often sends poorly formatted
				# messages that do not decode
				# we try and figure out who the message 
				# was supposed to goto, should be a
				# record of it in the agent's messages
				cmdDecoded <- list(msg=list(
					from=agent$id,
					to=agent$lastChatPartner,
					action="chat",
					msg=rawMsg
				))
			}

			# attempt to validate the command
			if(validate) {
				msgValidation <- self$validate(cmdDecoded$msg,agent)
				# check if we need to set from field,
				# should probably make a MSG an object
				# so that validate can do this itself
				if(msgValidation$setFrom) {
					cmdDecoded$msg$from <- agent$id
				}
			} else {
				msgValidation <- list(isValid=T)
			}
			# if the message is not valid
			if(!msgValidation$isValid) {
				response <- list(
					action="error",
					error=msgValidation$error
				)
				print("invalid message:")
				# we can still print invalid commands
				# as they are already parsed by the
				# transcoder
				self$printMsg(cmdDecoded)

				# send the "error" action to be executed
				return(self$execute(response,agent))
			}

			# if the AI is trying to chat to us, we
			# don't want to ask permission for that
			self$printMsg(cmdDecoded)
         #print("You may need to press enter to see prompt if not shown below")

			# do not as for permission if in continous mode
			if(config$continuous) {
				# execute the message
				return(self$execute(cmdDecoded$msg,agent))
			}

			permission <- agentManager$primaryHuman$askPermission(cmdDecoded)
			if(permission$choice=="c") {
				return(self$execute(cmdDecoded$msg,agent))
			} else if(permission$choice=="q") {
				response <- list(
					action="exit"
				)
				return(self$execute(response,agent))
			} else if(permission$choice=="i") {
				# respond the interaction
				# maybe this should not be "error"
				response <- list(
					action="interaction",
					msg=permission$msg
				)
				return(self$execute(response,agent))
			}
		},

		execute = function(cmdMsg,agent) {
			# if we are asked to exit, do so
			if(cmdMsg$action=="exit") {
				return()
			}

			# check if command was an "error" response
			if(cmdMsg$action=="error") {
				response <- list(
					from="C0",
					to=agent$id,
					action="chat",
					msg=cmdMsg$error
				)
				# send token count if enabled
				if(config$trackTokens) {
					response$tokens_used <- agent$tokensUsed
				}
				encResponse <- commandHandler$encodeCommand(
					response
				)
				return(commandHandler$handleCommand(encResponse,agent,validate=F))
			}

			if(cmdMsg$action=="interaction") {
				# send token count if enabled
				if(config$trackTokens) {
					cmdMsg$msg$tokens_used <- agent$tokensUsed
				}
				response <- commandHandler$encodeCommand(list(
					from="h0",
					to=agent$id,
					action="chat",
					msg=cmdMsg$msg
				))
				# do not validate this command
				return(response,agent,validate=F)
			}

			# call the command
			validate <- T
			r <- self$commands[[cmdMsg$action]]$f(cmdMsg)

			# if a null response was obtained do nothing
			# this is used by commands that themselves
			# call the commandHandler to return a msg
			if(is.null(r)) {
				return()
			}

			# if our request was not a chat request
			# we need to wrap the response in a chat
			# request so it gets routed correctly
			if(cmdMsg$action!="chat") {
				res <- list(
					from="C0",
					to=agent$id,
					action="chat",
					msg=r
				)
				# send token count if enabled
				if(config$trackTokens) {
					res$tokens_used <- agent$tokensUsed
				}
				response <- commandHandler$encodeCommand(res)
				# do not "validate" own commands
				validate <- F
			} else {
				# chat just take the response
				response <- r
			}

			# send token count if enabled
			#if(config$trackTokens) {
			#	response$tokens_used <- agent$tokensUsed
			#}

			commandHandler$handleCommand(response,agent,validate)
		},

		getANSIColor = function(colorNum) {
  			sprintf("\033[38;5;%dm", colorNum)
		},

		printField = function(name,value,color) {
			cat(color,name,' : ',commandHandler$encodeCommand(value),'\033[0m\n',sep="")
		},

		printMsg = function(cmdMsg) {
			commentColor <- "\033[38;5;93m"
			paramColor <- "\033[38;5;42m"
			actionColor <- "\033[38;5;214m"

			msg <- cmdMsg$msg
			# create a default
			cmd <- self$commands[[msg$action]]
			if("printMsg" %in% names(cmd)) {
				# print method override
				cmd$printMsg(msg)
			} else {
				# default print method
				self$printField("action",msg$action,actionColor)
				paramNames <- names(msg)[!names(msg) %in% c("action","comment")]
				# print params
				for(p in paramNames) {
					self$printField(p,msg[[p]],paramColor)
				}
				self$printField("comment",msg$comment,commentColor)
			}
			flush.console()
		},

		# encodes a command in the specified command format
		encodeCommand = function(msg,fmt=self$commandEncoding) {
			self$transcoders[[fmt]]$encode(msg)
		},

		# encodes a command in the specified command format
		decodeCommand = function(msg,fmt=self$commandEncoding) {
			self$transcoders[[fmt]]$decode(msg)
		}
	)
)
