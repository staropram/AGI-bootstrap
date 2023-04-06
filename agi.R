library(openai)
g_agent_count <- 0
g_agent_id <- 0

global <- new.env()

global$agents <- list()

agent_new <- function() {
	a <- list(
		id = paste0("a",g_agent_id),
		messages = list()
	)
	g_agent_count <- g_agent_count + 1
	g_agent_id <- g_agent_id + 1
	global$agents[[a$id]] <- a
	a$id
}

agent_append_msg <- function(agent_id,msg,role) {

	global$agents[[agent_id]]$messages <- c(global$agents[[agent_id]]$messages,list(list(
		"role" =role,"content"=msg
	)))
	#agent$messages <- append(agent$messages,
	#	paste0('{"role":"',role,'","content":"',msg,'"}')
	#)
}

agi_chat <- function(agent_id,msg) {
	agent_append_msg(agent_id,msg,"user")
	agent <- global$agents[[agent_id]]
	#browser()
	print(agent$messages)
	# Generate a completion
	completion <- create_chat_completion(
	  model = "gpt-3.5-turbo",
	  messages = agent$messages,
	  max_tokens = 1024,
	  n = 1,
	  stop = NULL,
	  temperature = 0.7
	)
	agent_append_msg(agent_id,completion$choices$message.content,"assistant")
	completion
}

exit <- F

# load the commands
source('load_commands.R')

f <- file("initial_prompt.txt","r")
initial_prompt <- paste(readLines(f),collapse="")
close(f)

a0_id <- agent_new()

agi_response <- agi_chat(a0_id,initial_prompt)

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
		print(msgRaw)
		print("respond to it: ")
		action_msg <- readline()
	} else {
		# print the action and comment for us to read
		print(paste("Requested action:",msg))
		x <- readline("Continue? y-yes n-no i-inject x-debug: ")
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



	agi_response <- agi_chat(a0_id,action_msg)

}
