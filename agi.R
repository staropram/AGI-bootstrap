library(openai)
library(R6)
library(jsonlite)

# if last run had an error whilst directory was changed 
# and we're in the runtime dir change it back to the root
setwd(strsplit(getwd(), "/runtime")[[1]][1])

source('color_output.R')

source("config.R")
source("Agent.R")
source("HumanAgent.R")
source("AgentManager.R")
source("CommandHandler.R")

load_initial_prompt <- function() {
	fn <- paste0("data/prompts/",config$initialPrompt)
	prompt <- paste(readLines(fn),collapse="")
	prompt
}

initial_prompt <- load_initial_prompt()

# check if a previous state exists
existingStateFile <- paste0(
	config$runtimeDirPrefix,"/",config$aiName,"/a0.rds"
)
# if it does, ask to restore
restoreState <- F
if(file.exists(existingStateFile)) {
	answer <- readline(paste0("Would you like to restore state for AI \"",config$aiName,"\"? (y/n) : "))
	if(answer=="y") {
		restoreState <- T
		# we do not want to clean the working directory
		# if we are restoring the state, so override this
		config$cleanWorkingDir <- F
	}
}

# create the command handler (this also sets up the
# working directory)
commandHandler <- CommandHandler$new(config)

# create agent manager 
agentManager <- AgentManager$new(config)

# create the main human agent
humanAgent <- agentManager$spawnHuman()

# if we are restoring the state we need to load the agent
# (future: all the agents, starting with the human agent)
# and tell the manager
if(restoreState) {
	# note that load puts the object back to the same
	# name it was stored under
	load(existingStateFile)
	agentManager$restoreAgent(a0)
	# we want to send an initial prompt which
	# tells the AI to continue in this case
	humanAgent$chatWithAgent("a0","Your state has been restored since you were last ran, please continue.")
} else {
	# otherwise we create a new agent
	a0 <- agentManager$newAgent()
	# and send the initial prompt
	humanAgent$chatWithAgent(a0$id,initial_prompt)
}


# this whole area of the code is pissing me off
# needs abstracting. Can be done via a HumanAgent
while(T) {
	# extract the command
	msgRaw <- a0_response$msg
	browser()
	if(msgRaw=="exit") {
		break
	}

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
				action_msg <- readline("Respond: ")
			} else if(a=="d") {
				browser()
			} else if(a=="q") {
				break
			}
		}
		if(a=="q") { break }
	} else {
		# print the action and comment for us to read
		commandHandler$printMsg(msg)
		if(msg$action=="exit") {
			break
		}
		a <- "z"
		while(a!="i") {
			if(config$continuous==T) {
				a <- "c"
			} else {
				a <- readline("c-continue, i-interact, d-debug, q-quit: ")
			}
			if(a=="i") {
				action_msg <- readline("Respond: ")
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
	# make sure the response goes to the correct agent
	a0_response <- a0$chat(action_msg)

	# save state, this will need managing separately
	# at some point, at the moment we just save a0 
	save(a0,file=existingStateFile)
}
