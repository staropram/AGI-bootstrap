command_show_command_source <- list(
	active=T,
	author="human",
	usage='{"action":"show_command_source","command_name":"name"} will show the R source for the specified command "name". The command has to be in the list of available commands.',
	f=function(args) {
		fn <- paste0("commands/",args$command_name,'.R')
		if(!file.exists(fn)) {
			return('{"error":"Invalid command"}')
		}
		f <- file(fn,"r")
		content <- paste(readLines(f),collapse="\n")
		close(f)
		content
	}
)

#args <- list()
#args$command_name <- "source_r_file"
#print(command_show_command_source$f(args))
