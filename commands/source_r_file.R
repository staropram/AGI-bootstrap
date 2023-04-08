command_source_r_file <- list(
	active=T,
	author="human",
	usage='{"action":"source_r_file","fn":"filename"} where filename is the filename you want to source into the R environment.',
	f=function(args) {
		op <- capture.output(source(args$fn))
		paste(op,collapse="")
	}
)
