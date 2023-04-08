library(openai)
library(R6)
library(jsonlite)

source("Agent.R")
source("AgentManager.R")
source("CommandHandler.R")
source("config.R")

setwd(config$root)

load_initial_prompt <- function() {
	fn <- paste0("data/prompts/",config$initialPrompt)
	prompt <- paste(readLines(fn),collapse="")
	prompt
}

initial_prompt <- load_initial_prompt()

commandHandler <- CommandHandler$new(config)

# create agent manager and add a new default agent
agentManager <- AgentManager$new(config)
a0 <- agentManager$newAgent()

# get the initial response
agi_response <- a0$chat(initial_prompt)

while(T) {
	# extract the command
	msgRaw <- agi_response$msg
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
		while(a!="i") {
			a <- readline("Cannot parse, i-interact, d-debug, q-quit: ")
			if(a=="i") {
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
		while(a!="i") {
			a <- readline("c-continue, i-interact, d-debug, q-quit: ")
			if(a=="i") {
				action_msg <- readline("Your response: ")
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

	print(action_msg)
	agi_response <- a0$chat(action_msg)

}
