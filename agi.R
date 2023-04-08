library(openai)
library(R6)
library(jsonlite)

source("Agent.R")
source("AgentManager.R")
source("CommandHandler.R")

commandHandler <- CommandHandler$new()

load_initial_prompt <- function() {
	f <- file("initial_prompt.txt","r")
	prompt <- paste(readLines(f),collapse="")
	close(f)
	prompt
}

initial_prompt <- load_initial_prompt()

# create agent manager and add a new default agent
agentManager <- AgentManager$new()
a0 <- agentManager$newAgent()

# get the initial response
agi_response <- a0$chat(initial_prompt)


while(T) {
	# extract the command
	msgRaw <- agi_response$choices$message.content
	msg <- tryCatch(fromJSON(msgRaw),
		error = function(e) {
			message <- conditionMessage(e)
			warning("An error occurred while parsing JSON: ", message)
			NULL
		}
	)

	# check if commands are valid

	if(is.null(msg)) {
		print("AGI fucked up")
		# XXX this needs to have the same recovery loop
		# as below
		print(msgRaw)
		print("respond to it: ")
		action_msg <- readline()
	} else {
		# print the action and comment for us to read
		print(paste("Requested action:",msg))
		x <- readline("Continue? y-yes n-no i-inject x-debug: ")
		# XXX make this a loop so we can debug then inject
		if(x=="n") {
			break
		} else if(x=="x") {
			browser()
		} else if(x=="i") {
			print("respond to him: ")
			action_msg <- readline()
		} else if(x=="y") {
			action_msg <- commandHandler$executeCommand(msg)
		}
	}



	agi_response <- a0$chat(action_msg)

}
