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
	commandValidity <- commandHandler$validate(msg)
	if(!commandValidity$isValid) {
		# as below
		print(msgRaw)
		a <- "z"
		while(a!="r") {
			a <- readline("Cannot parse, r-respond, d-debug, q-quit: ")
			if(a=="r") {
				action_msg <- readline()
			} else if(a=="d") {
				browser()
			} else if(a=="q") {
				break
			}
		}
		if(a=="q") { break }
	} else {
		# print the action and comment for us to read
		print(paste("Requested action:",msg))
		a <- "z"
		while(a!="r") {
			a <- readline("c-continue, r-respond, d-debug, q-quit: ")
			if(a=="r") {
				action_msg <- readline()
			} else if(a=="d") {
				browser()
			} else if(a=="q") {
				break
			} else if(a=="c") {
				action_msg <- commandHandler$execute(msg)
				break
			}
		}
		if(a=="q") { break }
	}

	agi_response <- a0$chat(action_msg)

}
