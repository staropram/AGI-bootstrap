library(openai)
library(R6)
library(jsonlite)

global <- new.env()

global$agents <- list()

AgentManager <- R6Class(
	"AgentManager",
	public = list(
		agents = list(),
		agentCount = 0,
		agentIDSeq = 0,

		initialize = function() {},

		addAgent = function(agent) {
			self$agents[[agent$id]] <- agent 
			#c(self$agents,list(id=agent))
		},

		newAgent = function() {
			agent <- Agent$new(self$agentIDSeq)
			self$agentIDSeq <- self$agentIDSeq + 1
			self$agentCount <- self$agentCount + 1
			self$addAgent(agent)
			agent
		}

	)
)

Agent <- R6Class(
	"Agent",
	public = list(
		id = "",
		messages = list(),

		initialize = function(id) {
			self$id <- paste0("a",id)
		},

		appendMessage = function(role,msg) {
			self$messages <- c(self$messages,list(list(
				"role" =role,"content"=msg
			)))
		},

		chat = function(msg) {
			self$appendMessage("user",msg)
			print(self$messages)
			completion <- create_chat_completion(
			  model = "gpt-3.5-turbo",
			  messages = self$messages,
			  max_tokens = 1024,
			  n = 1,
			  stop = NULL,
			  temperature = 0.7
			)
			self$appendMessage("assistant",completion$choices$message.content)
			completion
		}
	)
)

agentManager <- AgentManager$new()

# load the commands
source('load_commands.R')

load_initial_prompt <- function() {
	f <- file("initial_prompt.txt","r")
	prompt <- paste(readLines(f),collapse="")
	close(f)
	prompt
}

initial_prompt <- load_initial_prompt()

a0 <- agentManager$newAgent()

agi_response <- a0$chat(initial_prompt)

process_action <- function(msg) {
	agi_commands[[msg$action]]$f(msg)
}

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
			action_msg <- process_action(msg)
		}
	}



	agi_response <- a0$chat(action_msg)

}
