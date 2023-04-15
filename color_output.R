get_ansi_color <- function(color_number) {
  sprintf("\033[38;5;%dm", color_number)
}

# Define ANSI escape codes for colors
commentColor <- get_ansi_color(93)
paramColor <- get_ansi_color(42)
actionColor <- get_ansi_color(214)
resetColor <- "\033[0m"

print_action <- function(action) {
	cat(actionColor,"action: \"",action,"\"",resetColor,"\n",sep="")
}

print_comment <- function(comment) {
	cat(commentColor,"comment: \"",comment,"\"",resetColor,"\n",sep="")
}

print_param <- function(paramName,paramValue) {
	if(nchar(paramValue)>300) {
		#cat(paramColor,paramName,": \"",substring(paramValue,0,300),"...[TRUNCATED\"",resetColor,"\n",sep="")
		cat(paramColor,paramName,": \"",paramValue,"\"",resetColor,"\n",sep="")
	} else {
		cat(paramColor,paramName,": \"",paramValue,"\"",resetColor,"\n",sep="")
	}
}

#print_action("test_action")
#print_comment("test_comment")
#print_param("test_param")
