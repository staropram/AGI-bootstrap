JSONTranscoder <- R6Class(
	"JSONTranscoder",
	inherit=MessageTranscoder,
	public=list(

		initialize=function() {
			super$initialize("JSON","R","JSON")
		},

		# R -> JSON
		encode=function(msg) {
			# this will always work as the R comes direct
			toJSON(msg,auto_unbox=T)
		},

		# JRON -> R
		decode=function(msg) {
			# this can fuck-up since the decode might fail
			decoded <- tryCatch(fromJSON(msg),
				error = function(e) {
					errorMsg <- conditionMessage(e)
					warning("An error occurred while parsing JSON: ", message)
					NULL
				}
			)
			if(is.null(decoded)) {
				return(
					list(success=F,error=errorMsg,msg=msg)
				)
			}
			list(
				success=T,
				origMsg=msg,
				msg=decoded
			)
		}
	)
)
