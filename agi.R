source("check_deps.R")
library(openai)
library(R6)
library(jsonlite)
library(promises)
library(future)
plan(multicore)

source("config.R")

# first time we run keep track of root directory
if(!exists("config$rootDir")) {
	config$rootDir <- getwd()
}
# it's possible an error occurred while we were in
# the working directory so switch back to global root
setwd(config$rootDir)

source('color_output.R')

source("FakeAI.R")
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

# set the runtime dir in the config so that
# other functions can use it
config$runtimeDir <- paste0(config$runtimeDirPrefix,"/",config$aiName)


# check if a previous state exists
existingStateFile <- paste0(
	config$runtimeDir,"/",config$aiName,".rds"
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
	agentManager$restoreAgent(primaryAgent$id)
	# we want to send an initial prompt which
	# tells the AI to continue in this case
	humanAgent$chatWithAgent(primaryAgent$id,"Your state has been restored since you were last ran, please continue.")
} else {
	# otherwise we create a new agent
	primaryAgent <- agentManager$newAgent()
	# and send the initial prompt
	humanAgent$chatWithAgent(primaryAgent$id,initial_prompt)
}

#	save(primaryAgent,file=existingStateFile)
