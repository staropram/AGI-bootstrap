# load the commands
CommandHandler <- R6Class(
	"CommandHandler",
	public = list(
		commands = list(),
		commandList = list(),
		commandNames = list(),

		initialize = function() {
			self$loadCommands()
		},

		loadCommands = function() {
			command_files <- list.files("commands")
			self$commands <- lapply(command_files,function(fn) {
				cmd_name <- sub("\\.R$", "", fn)
				source(paste0("commands/",fn))
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
			self$commands[[msg$action]]$f(msg)
		}
	)
)
