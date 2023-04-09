# Summary
The purpose of this project is to see if an LLM (such as chatgpt) can bootstrap itself towards AGI.

Think of it like an AI escape room, where we can test how much the AI can do with basic commands.

A really clever AI would only need file operations (inc execute) and the ability to ask user for help (such as an API key). Such an AI could create any commands it needs: internet lookup, structs, long term memory, custom NN, etc.

# Getting started

Take a look at the config template "config.R":

```r
config <- list(
	chatType="chatgpt",
	aiName="test0",
	runtimeDirPrefix="runtime",
	initialPrompt="agi_prompt_v0.1.txt",
	continuous=F,
	cleanWorkingDir=T,

	# ChatGPT options
	chatgpt = list(
		model = "gpt-3.5-turbo",
		max_tokens = 1024
	),

	# FakeGPT options
	fakegpt = list(
		script = "create_file_test",
		artificialDelaySecs = 1
	)
)
```

`chatType` can be either "chatgpt" or "fakegpt". 

"chatgpt" uses OpenAI's chatgpt API as a backend so you need to put you API key in the environment variable `OPENAI_API_KEY`

"fakegpt" is a testing framework that reads scripts from `data/fakegpt/scripts`

## Adding commands

Available commands are in the "commands" directory, initial prompt is in "initial_prompt.txt"

# TODO

1. add create_commmand command
2. add create_function command
3. add execute_function command
4. make it so the AI can send a command embedded in text
and extract that command if necessary
5. AI also sends command sequences so maybe queue and execute commands if this happens
