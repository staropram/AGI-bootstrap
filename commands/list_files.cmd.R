command_list_files <- list(
  author = "human",
  usage = list(
  		action="list_files",
		comment="List the files in the working directory."
	),
  f = function(args) {
	  list(
		  files <- paste0(list.files(config$runtimeDir),collapse=",")
	  )
  }
)
