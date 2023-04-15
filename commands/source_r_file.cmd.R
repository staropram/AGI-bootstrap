command_source_r_file <- list(
	active=T,
	author="human",
	usage=list(
		action="source_r_file",
		fn="filename",
		comment="Sources given filename into the R environment. Output will be passed back to you via capture.output"
	),
	f=function(args) {
		fn <- paste0(config$runtimeDir,"/",args$fn)
		if(!file.exists(fn)) {
			return(paste0('{"error":"File\"',fn,'\"does not exist"}'))
		}
		op <- capture.output(source(fn))
		paste(op,collapse="")
	}
)
