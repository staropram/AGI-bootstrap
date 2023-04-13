FakeAI <- R6Class(
	"FakeAI",
	public = list(
		config = NULL,
		script = list(),
		scriptIndex = 0,

		initialize = function(config) {
			self$config <- config
			# legacy
			#self$script <- loadJSONScript(config$fakegpt$script)
			self$script <- loadRScript(config$fakegpt$script)
		},

		loadJSONScript = function(scriptName) {
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
		},

		loadRScript = function(scriptName) {
			fn <- paste0("data/fakeai/scripts/",scriptName,".R")
			source(fn)
			scriptDataName <- paste0("script_",scriptName)
			self$script <- get(scriptDataName)
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
