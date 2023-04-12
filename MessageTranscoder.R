MessageTranscoder <- R6Class(
	"MessageTranscoder",
	public=list(
		name=NULL,
		formats=NULL,

		initialize=function(name,formatA,formatB) {
			self$name <- name
			self$formats <- list(formatA,formatB)
		},

		# A -> B
		encode=function(msg) {
			stop("Subclasses must implement encode method")
		},

		# B -> A
		decode=function(msg) {
			stop("Subclasses must implement decode method")
		}
	)
)
