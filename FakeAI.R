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
			self$script <- self$loadRScript(config$fakegpt$script)
		},

		loadJSONScript = function(scriptName) {
			fn <- paste0(config$rootDir,"/data/fakeai/scripts/",scriptName,".json")
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
			fn <- paste0(config$rootDir,"/data/fakeai/scripts/",scriptName,".R")
			source(fn)
			scriptDataName <- paste0("script_",scriptName)
			self$script <- get(scriptDataName)
		},

		syncChat = function(msg) {
			self$scriptIndex <- self$scriptIndex + 1
			if(self$scriptIndex==(length(self$script)+1)) {
				self$scriptIndex <- 1
			}
			commandHandler$encodeCommand(self$script[[self$scriptIndex]])
		},

		chat = function(msg,agent) {
			# we don't care about the message as we
			# just issue a fixed sequence of commands
			self$scriptIndex <- self$scriptIndex + 1
			if(self$scriptIndex==(length(self$script)+1)) {
				self$scriptIndex <- 1
			}

			completion <- future({
				commandHandler$encodeCommand(self$script[[self$scriptIndex]])
			})
			#print(paste0("fakeAI responds: ",response))
			completion %...>% (function(r) {
				  commandHandler$handleCommand(r,agent)
			})
			NULL
		}
	)
)
