# load the commands
CommandHandler <- R6Class(
	"CommandHandler",
	public = list(
		config = NULL,
		commands = NULL,
		commandList = NULL,
		commandNames = NULL,
		workingDir = "",
		commandFiles=NULL,

		initialize = function(config) {
			self$config <- config
			self$workingDir <- paste0(
				config$runtimeDirPrefix,"/",
				config$aiName
			)

			self$commandFiles <-list.files("commands",pattern="*.cmd.R")

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
			for(f in self$commandFiles) {
				file.copy(paste0("commands/",f),self$workingDir,overwrite=T)
			}

			self$loadCommands()
		},

		loadCommands = function() {
			self$commands <- lapply(self$commandFiles,function(fn) {
				cmd_name <- sub("\\.cmd\\.R$", "", fn)
				source(paste0(self$workingDir,"/",fn))
				file_content <- get(paste0("command_",cmd_name))
				sc <- list()
				sc[[cmd_name]] <- file_content
				get(paste0("command_",cmd_name))
			})
			names(self$commands) <- sub("\\.cmd\\.R$","",self$commandFiles)
			self$commandList <- lapply(self$commands,function(cmd) {
				if(!cmd$active) {
					return(NULL)
				}
				cmd$usage 
			})
			# remove inactives, xxx not sure we should do this
			# maybe just keep track of which are active dynamically
			self$commandList <- Filter(Negate(is.null),self$commandList)

			self$commandNames <- names(self$commands)
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
			self$commands[[msg$action]]$printMsg(msg)
		}
	)
)
