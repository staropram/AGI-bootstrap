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
		commandFormat = NULL,
		transcoders = list(),

		initialize = function(config) {
			self$config <- config
			self$workingDir <- paste0(
				config$runtimeDirPrefix,"/",
				config$aiName
			)
			self$commandFormat = config$commandFormat

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

		execute = function(msg) {
			currentDir <- getwd()
			setwd(self$workingDir)
			output <- self$commands[[msg$action]]$f(msg)
			setwd(currentDir)
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
		encodeCommand = function(msg,fmt=self$messageFormat) {
			self$transcoders[[fmt]]$encode(msg)
		},

		# encodes a command in the specified command format
		decodeCommand = function(msg,fmt=self$messageFormat) {
			self$transcoders[[fmt]]$decode(msg)
		}
	)
)
