command_files <- list.files("commands")
agi_commands <- lapply(command_files,function(fn) {
	cmd_name <- sub("\\.R$", "", fn)
	source(paste0("commands/",fn))
	file_content <- get(paste0("command_",cmd_name))
	sc <- list()
	sc[[cmd_name]] <- file_content

	return(sc)
})[[1]]


command_list_commands <- list(
	usage='{"action":"list_commands"} returns list of possible commands',
	f=function(args) {
		toJSON(agi_commands_list)
	}
)
agi_commands[["list_commands"]] <- command_list_commands

agi_commands_list <- lapply(agi_commands,function(cmd) { cmd$usage })

