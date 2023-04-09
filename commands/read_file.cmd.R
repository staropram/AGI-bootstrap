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
    paste0('{"status" = "ok", "content" = ',content,'}')
  },

  # print the message
  printMsg = function(msg) {
    cat(red, paste0("action: ", msg$action), reset, "\n")
    cat(green, paste0("fn: ", msg$fn), reset, "\n")
    cat(green, paste0("comment: ", msg$comment), reset, "\n")
  }
)
