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
		validate = function(msg) {
			if(is.null(msg)) {
				return(list(
					isValid=F
				))
			}
			if(is.null(msg$action)) {
				return(list(
					isValid=F
				))
			}
			list(
				isValid=msg$action %in% self$commandNames
			)
		},

		# this receives an encoded message from any agent
		# and must attempt to decode the message and
		# properly handle it
		handleCommand = function(rawMsg,agent) {

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
			msgValidation <- self$validate(cmdDecoded$msg)
			# if the message is not valid
			if(!msgValidation$isValid) {
				response <- list(
					error="Unrecognised command"
				)
				browser()
				return(commandHandler$encodeCommand(response))
			}

			# if the AI is trying to chat to us, we
			# don't want to ask permission for that
			self$printMsg(cmdDecoded)

			# do not as for permission if in continous mode
			if(config$continuous) {
				# execute the message
				return(self$execute(cmdDecoded$msg,agent))
			}

			permission <- agentManager$primaryHuman$askPermission(cmdDecoded)
			if(permission$hasPermission) {
				cmdResult <- self$execute(cmdDecoded$msg)
			} else {
				# send some sort of message to the AI
				# explaining why they can't continue
			}
		},

		execute = function(cmdMsg,agent) {
			if(cmdMsg$action=="exit") {
				return()
			}
			r <- self$commands[[cmdMsg$action]]$f(cmdMsg)

			# if a null response was obtained do nothing
			if(is.null(r)) {
				return()
			}

			# if our request was not a chat request
			# we need to wrap the response in a chat
			# request so it gets routed correctly
			if(cmdMsg$action!="chat") {
				response <- commandHandler$encodeCommand(list(
					to=agent$id,
					action="chat",
					msg=r
			 	))
			} else {
				response <- r
			}

			commandHandler$handleCommand(response,agent)
		},

		printMsg = function(cmdMsg) {
			msg <- cmdMsg$msg
			# create a default
			cmd <- self$commands[[msg$action]]
			if("printMsg" %in% names(cmd)) {
				# print method override
				cmd$printMsg(msg)
			} else {
				# default print method
				print_action(msg$action)
				paramNames <- names(msg)[!names(msg) %in% c("action","comment")]
				# print params
				for(p in paramNames) {
					print_param(p,msg[[p]])
				}
				print_comment(msg$comment)
			}
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
