command_download_file <- list(
	author="human",
	usage=list(
		action="download_file",
		url="URL of file",
      filename="Name to save it to",
		comment="Downloads spcified file to the working directory"
	),
	f=function(args) {
      fn <- paste0(config$runtimeDir,"/",args$filename)
      cmdResponse <- download.file(args$url, fn, mode = "wb")

      response <- list(
         status="OK"
      )
      if(cmdResponse!=0) {
         response$status="Failed to download"
      }
      commandHandler$encodeCommand(response)
	}
)
