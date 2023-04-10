# Summary
CAVEAT: This is a work in progress and we are at the beginning of that progress. Things may rapidly change or break. Main external limitation here is context length.

The purpose of this project is to see if an LLM such as chatgpt can bootstrap itself towards AGI. (could also be pointed toward any goal however)

Think of it like an AI escape room, where we can test how much the AI can do with basic commands.

A really clever AI would only need file operations (inc execute) and the ability to ask user for help (such as an API key). Such an AI could create any commands it needs: internet lookup, structs, long term memory, custom NN, etc.

# Getting started

TLDR: edit `config.R` and then `source("agi.R")` within R.

The system is interactive (see `continuous` option to override). At the present time chatgpt3.5 needs a bit of help and I've noticed that sometimes it is way dumber than other times, so I think OpenAI throttles performance sometimes.

Sometimes chatgpt3.5 will respond with something that isn't a command so you need to tell it to continue with commands, or you can have a conversation with it if you like.

Or sometimes chatgpt3.5 will mix a command with text. Usually you can just respond with:

"send only json"

And it will then send the correct command. It is on the TODO list to try and figure out what it is trying to do. chatgpt4 is unlikely to do this.

Think of this more as a collaboration with the AI, eventually the interventions should be less and less as the AI makes useful suggestions.

# Config

Take a look at the config template `config.R`:

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
		max_tokens = 1024,
        temperature = 0.7
	),

	# FakeGPT options
	fakegpt = list(
		script = "create_file_test",
		artificialDelaySecs = 1
	)
)
```

## General options

| Option  | Description |
| ------- | ----------- |
|`chatType` | can be either "chatgpt" or "fakegpt". "chatgpt" uses OpenAI's chatgpt API as a backend so you need to put you API key in the environment variable `OPENAI_API_KEY`. "fakegpt" is a testing framework that reads scripts from `data/fakegpt/scripts`|
| `aiName` | is the name of the AI and will be the name of the working directory inside the runtime directory.|
| `runtimeDirPrefix` | the prefix of the runtime directory (relative to the root). Should probably make this an absolute path in the future.|
| `initialPrompt` | the prompt that will be sent to the chatgpt/fakegpt to set out the goals of the system, message format, constraints etc. At the moment the goal is to become an AGI but you could put any task here. Prompts are kept in `data/prompts`|
| `continuous` | is a boolean indicating whether the AGI bootstrap should run continuously or ask for confirmation before each step.|
|`cleanWorkingDir` |is a boolean indicating whether the AIs working directory should be erased before starting. This is useful for testing, but if the AI creates a bunch of stuff you might not want to do this. Note that this option is set to false if you answer yes to restoring the state of a previous run.|

## Chat model options
### ChatGPT

| Option  | Description |
| ------- | ----------- |
| `model` | is the OpenAI model to use for the chat endpoint, for example "gpt-3.5-turbo". |
| `max_tokens` | limits the maximum tokens in any given response. |
| `temperature` | chatgpt temperature parameter. |

### FakeGPT

| Option  | Description |
| ------- | ----------- |
| `script`| the script to run |
| `artificialDelaySecs` | adds an artifical delay so you can read the responses rather than it all happening in a blur. |

# Adding commands

The commands that have so far been defined are in the `commands` directory. These are copied to the AIs working directory upon initialisation.

# Notes

You might want to disable certain commands. Personally, I'm interested in seeing it try and figure things out for itself. If you give it the ability to search the internet and spawn agents, it just uses them all the time, which is a bit lame as it doesn't really need to. I want to know what the LLM is intrinsically capable of.

# Testing

Testing is done using the "fakegpt" chat interface.

# TODO

1. add `create_commmand` command
2. add `create_function` command
3. add `execute_function` command
4. ChatGPT 3.5 likes to interject text outside of the JSON messages which is annoying and breaks command processing. So the command processing should be less fragile and deal with this in some sane manner.
5. AI also liks to send command sequences in a single message so could create a command queue and handle this.
6. Make sure each command can print itself
7. Probably should group commands and allow multiple endpoints per command to increase coupling.
8. AI needs to be able to reflect on all the source code, not just the commands.
9. It is relatively easy to exceed the maximum context length. I think we need to ask the AI to compress it's context periodically
10. It might make sense to make the commands an R package so they have a namespace
