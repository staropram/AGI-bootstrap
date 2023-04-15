command_list_files <- list(
  author = "human",
  usage = list(
		from="from_id",
		to="to_id",
  		action="list_files",
		comment="List the files in the working directory."
	),
  f = function(args) {
		paste0(list.files(config$runtimeDir),collapse=",")
  }
)
