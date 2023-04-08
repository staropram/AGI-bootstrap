FakeAI <- R6Class(
	"FakeAI",
	public = list(
		config = NULL,
		script = list(),
		scriptIndex = 1,

		initialize = function(config) {
			self$config <- config
			scriptName <- config$fakegpt$script
			# load the script
			self$scriptIndex <- fromJSON(paste0("data/fakeai/scripts/scriptName"))
		},

		chat = function(msg) {
			# we don't care about the message as we
			# just issue a fixed sequence of commands

		}
	)
)
