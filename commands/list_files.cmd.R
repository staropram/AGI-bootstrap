command_list_files <- list(
  active = T,
  author = "human",
  usage = '{"action":"list_files","comment":"List the files in the working directory."}',
  f = function(args) {
	  toJSON(list(files=list.files()))
  }
)
