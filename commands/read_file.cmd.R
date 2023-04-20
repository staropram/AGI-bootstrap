command_read_file <- list(
	active = T,
	author = "AI and human",
	usage = list(
		action="read_file",
		fn="filename",
		comment="Reads the contents of the specified file."
	),

	f = function(args) {
		fn <- paste0(config$runtimeDir,"/",args$fn)
		# check the file exists
		if(!file.exists(fn)) {
			return(paste0('{"error":"',fn,' does not exist"}'))
		}
		content <- paste0(readLines(fn),collapse="\n")
      response <- list(
         status = "OK",
         content = content
      )
	}
)
