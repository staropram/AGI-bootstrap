command_show_command_source <- list(
	active=T,
	author="human",
	usage=list(
		action="show_command_source",
		command_name="name",
		comment="Shows the R source for the specified command \"name\"."
	),

	f=function(args) {
		fn <- paste0(config$runtimeDir,"/",args$command_name,'.cmd.R')
		if(!file.exists(fn)) {
			return(paste0('{"error":"Command',args$command_name,' does not exist"}'))
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
