command_read_file <- list(
  active = T,
  author = "AI and human",
  usage = '{"action":"read_file","fn":"filename","comment":"Reads the contents of the specified file."}',
  f = function(args) {
	 # check the file exists
	 if(!file.exists(args$fn)) {
		return('{"error":"file does not exist"}')
	 }
    content <- readLines(args$fn)
    paste0('{"status" = "ok", "content" = "',content,'"}')
  },

  # print the message
  printMsg = function(msg) {
		print_action(msg$action)
		print_param("fn",msg$fn)
		print_comment(msg$comment)
  }
)
