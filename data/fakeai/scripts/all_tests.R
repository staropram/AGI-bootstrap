script_all_tests <- {
	prefix <- "data/fakeai/scripts/"
	allCommands <- unlist(lapply(list.files(prefix),function(fn) {
		if(fn=="all_tests.R") {
			return(NULL)
		}
		source(paste0(prefix,fn))
		scriptRName <- paste0("script_",gsub(".R$","",fn))
		currentScript <- get(scriptRName)
		currentScript[1:(length(currentScript)-1)]
   }),recursive=F)
	allCommands <- c(allCommands,list(list(from="a0",action="exit")))
	allCommands
}
