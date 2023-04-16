command_write_file <- list(
	active=T,
	author="human",
	usage=list(
		action="write_file",
		fn="filename",
		content="filecontents",
		comment="Writes filecontents to the specified file"
	),
	f=function(args) {
		fn <- paste0(config$runtimeDir,"/",args$fn)
		writeLines(args$content,fn)
      response <- list(
         status="OK"
      )
      commandHandler$encodeCommand(response)
	}
)
