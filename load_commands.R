command_files <- list.files("commands")
agi_commands <- lapply(command_files,function(fn) {
	cmd_name <- sub("\\.R$", "", fn)
	source(paste0("commands/",fn))
	file_content <- get(paste0("command_",cmd_name))
	sc <- list()
	sc[[cmd_name]] <- file_content

	#return(sc)
	get(paste0("command_",cmd_name))
})
names(agi_commands) <- sub("\\.R$","",command_files)

agi_commands_list <- lapply(agi_commands,function(cmd) {
	if(!cmd$active) {
		return(NULL)
	}
	cmd$usage 
})
# remove inactives, xxx not sure we should do this
# maybe just keep track of which are active dynamically
agi_commands_list <- Filter(Negate(is.null),agi_commands_list)

# add a list commands command
command_list_commands <- list(
	usage='{"action":"list_commands"} returns list of possible commands',
	f=function(args) {
		toJSON(agi_commands_list)
	}
)
agi_commands[["list_commands"]] <- command_list_commands
