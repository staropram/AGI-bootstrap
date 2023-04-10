FakeAI <- R6Class(
	"FakeAI",
	public = list(
		config = NULL,
		script = list(),
		scriptIndex = 0,

		initialize = function(config) {
			self$config <- config
			scriptName <- config$fakegpt$script
			fn <- paste0("file://data/fakeai/scripts/",scriptName,".json")
			# load the script
			scriptRaw <- readLines(fn)

			script <- tryCatch(fromJSON(scriptRaw,simplifyVector=F),
				error = function(e) {
					message <- conditionMessage(e)
					warning("An error occurred while parsing JSON: ", message)
					browser()
					NULL
				}
			)
			self$script <- script$commands
		},

		chat = function(msg) {
			# we don't care about the message as we
			# just issue a fixed sequence of commands
			self$scriptIndex <- self$scriptIndex + 1
			if(self$scriptIndex==(length(self$script)+1)) {
				self$scriptIndex <- 1
			}
			toJSON(self$script[[self$scriptIndex]],auto_unbox=T)
		}
	)
)
