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

	global$agents[[agent_id]]$messages <- c(global$agent[[agent_id]]$messages,list(list(
		"role" =role,"content"=msg
	)))
	#agent$messages <- append(agent$messages,
	#	paste0('{"role":"',role,'","content":"',msg,'"}')
	#)
}

agi_chat <- function(agent_id,msg) {
	agent_append_msg(agent_id,msg,"user")
	agent <- global$agents[[agent_id]]
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

# send the first message to the AGI
comp <- agi_chat(a0_id,initial_prompt)
