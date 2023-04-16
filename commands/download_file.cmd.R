command_download_file <- list(
	author="human",
	usage=list(
		action="download_file",
		url="URL of file",
      fn="Filename to save it to",
		comment="Downloads spcified file to the working directory"
	),
	f=function(args) {
      fn <- paste0(config$runtimeDir,"/",args$fn)

		cmdResponse <- tryCatch(
			{
				suppressWarnings(download.file(args$url, fn, mode = "wb"))
				list(
					status = "OK"
				)
			},
			error=function(e) {
				list(
					status ="error",
					msg = e$message
				)
			}
		)

      commandHandler$encodeCommand(cmdResponse)
	}
)
