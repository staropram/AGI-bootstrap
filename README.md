# Summary
The purpose of this project is to see if an LLM such as chatgpt can bootstrap itself towards AGI. (could also be pointed toward any goal however)

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

## General options

`chatType` can be either "chatgpt" or "fakegpt". 

"chatgpt" uses OpenAI's chatgpt API as a backend so you need to put you API key in the environment variable `OPENAI_API_KEY`

"fakegpt" is a testing framework that reads scripts from `data/fakegpt/scripts`

`aiName` is the name of the AI and will be the name of the working directory inside the runtime directory.

`runtimeDirPrefix` is the prefix of the runtime directory (relative to the root). Should probably make this an absolute path in the future.

`initialPrompt` this is the prompt that will be sent to the chatgpt/fakegpt to set out the goals of the system, message format, constraints etc. At the moment the goal is to become an AGI but you could put any task here. Prompts are kept in `data/prompts`

`continuous` is a boolean indicating whether the AGI bootstrap should run continuously or ask for confirmation before each step.

`cleanWorkingDir` is a boolean indicating whether the AIs working directory should be erased before starting. This is useful for testing, but if the AI creates a bunch of stuff you might not want to do this.

## Chat model options
### ChatGPT

`model` is the OpenAI model to use for the chat endpoint, for example "gpt-3.5-turbo".

`max_tokens` limits the maximum tokens in any given response.

### FakeGPT

| Command | Description |
| ------- | ----------- |
| `script`| the script to run |


`artificialDelaySecs` adds an artifical delay so you can
read the responses rather than it all happening in a blur.

## Adding commands

The commands that have so far been defined are in the `commands` directory. These are copied to the AIs working directory upon initialisation.

# TODO

1. add create_commmand command
2. add create_function command
3. add execute_function command
4. make it so the AI can send a command embedded in text
and extract that command if necessary
5. AI also sends command sequences so maybe queue and execute commands if this happens
