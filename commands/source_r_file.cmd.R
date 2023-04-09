command_source_r_file <- list(
	active=T,
	author="human",
	usage='{"action":"source_r_file","fn":"filename","comment":"Sources given filename into the R environment. Output will be passed back to you via capture.output."}',
	f=function(args) {
		if(!file.exists(args$fn)) {
			return(paste0('{"error":"File\"',args$fn,'\"does not exist"}'))
		}
		op <- capture.output(source(args$fn))
		paste(op,collapse="")
	}
)
