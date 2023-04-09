# load the commands
CommandHandler <- R6Class(
	"CommandHandler",
	public = list(
		config = NULL,
		commands = NULL,
		commandList = NULL,
		commandNames = NULL,
		commandDir = "",

		initialize = function(config) {
			self$config <- config
			self$commandDir <- paste0(
				config$runtimeDirPrefix,"/",
				config$aiName
			)
			# create directory if necessary
			if(!dir.exists(self$commandDir)) {
				dir.create(self$commandDir)
			}
			# copy the base commands into the runtime dir
			for(f in list.files("commands")) {
				file.copy(paste0("commands/",f),self$commandDir,overwrite=T)
			}

			self$loadCommands()
		},

		loadCommands = function() {
			command_files <- list.files(self$commandDir)
			self$commands <- lapply(command_files,function(fn) {
				cmd_name <- sub("\\.R$", "", fn)
				source(paste0(self$commandDir,"/",fn))
				file_content <- get(paste0("command_",cmd_name))
				sc <- list()
				sc[[cmd_name]] <- file_content
				get(paste0("command_",cmd_name))
			})
			names(self$commands) <- sub("\\.R$","",command_files)
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
			list(
				isValid=msg$action %in% self$commandNames
			)
		},

		execute = function(msg) {
			currentDir <- getwd()
			setwd(self$commandDir)
			output <- self$commands[[msg$action]]$f(msg)
			setwd(currentDir)
			output
		}
	)
)