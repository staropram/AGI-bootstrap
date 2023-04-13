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
		handleCommand = function(rawMsg) {
			# attempt to decode the message
			cmdDecoded <- self$decodeCommand(rawMsg)
			# if we cannot decode
			if(!cmdDecoded$success) {
				# pass back to the first human agent
				# XXX
			}
			# attempt to validate the command
			msgValidation <- self$validate(cmdDecoded$msg)
			# if the message is not valid
			if(!msgValidation$isValid) {
				# XXX
			}

			# execute the message
			self$execute(cmdDecoded$msg)
		},

		execute = function(cmdMsg) {

			print("execute")
			browser()
			output <- self$commands[[cmdMsg$action]]$f(cmdMsg)
			output
		},

		printMsg = function(msg) {
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
