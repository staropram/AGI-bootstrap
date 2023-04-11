command_read_file <- list(
  active = T,
  author = "AI and human",
  usage = '{"action":"read_file","fn":"filename","comment":"Reads the contents of the specified file."}',
  f = function(args) {
	 # check the file exists
	 if(!file.exists(args$fn)) {
		return('{"error":"file does not exist"}')
	 }
    content <- paste0(readLines(args$fn),collapse="\n")
    paste0('{"status" = "ok", "content" = "',content,'"}')
  }
)
