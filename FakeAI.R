FakeAI <- R6Class(
	"FakeAI",
	public = list(
		config = NULL,
		script = list(),
		scriptIndex = 0,

		initialize = function(config) {
			self$config <- config
			scriptName <- config$fakegpt$script
			fn <- paste0("file://data/fakeai/scripts/",scriptName,".txt")
			# load the script
			self$script <- readLines(fn)
		},

		chat = function(msg) {
			# we don't care about the message as we
			# just issue a fixed sequence of commands
			self$scriptIndex <- self$scriptIndex + 1
			if(self$scriptIndex==(length(self$script)+1)) {
				self$scriptIndex <- 1
			}
			self$script[[self$scriptIndex]]
		}
	)
)
