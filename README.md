# Summary
The purpose of this project is to see if an LLM such as chatgpt can bootstrap itself towards AGI. (could also be pointed toward any goal however)

Think of it like an AI escape room, where we can test how much the AI can do with basic commands.

A really clever AI would only need file operations (inc execute) and the ability to ask user for help (such as an API key). Such an AI could create any commands it needs: internet lookup, structs, long term memory, custom NN, etc.

# Getting started

TLDR: edit `config.R` and then `source("agi.R")` within R.

The system is interactive (see `continuous` option to override). At the present time chatgpt3.5 needs a bit of help and I've noticed that sometimes it is way dumber than other times, so I think OpenAI throttles performance sometimes.

Sometimes chatgpt3.5 will respond with something that isn't a command so you need to tell it to continue.

Or sometimes chatgpt3.5 will mix a command with text. Usually you can just respond with:

"send only json"

And it will then send the correct command. It is on the tTODO list to try and figure out what it is trying to do.


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

| Option  | Description |
| ------- | ----------- |
|`chatType` | can be either "chatgpt" or "fakegpt". "chatgpt" uses OpenAI's chatgpt API as a backend so you need to put you API key in the environment variable `OPENAI_API_KEY`. "fakegpt" is a testing framework that reads scripts from `data/fakegpt/scripts`|
| `aiName` | is the name of the AI and will be the name of the working directory inside the runtime directory.|
| `runtimeDirPrefix` | the prefix of the runtime directory (relative to the root). Should probably make this an absolute path in the future.|
| `initialPrompt` | the prompt that will be sent to the chatgpt/fakegpt to set out the goals of the system, message format, constraints etc. At the moment the goal is to become an AGI but you could put any task here. Prompts are kept in `data/prompts`|
| `continuous` | is a boolean indicating whether the AGI bootstrap should run continuously or ask for confirmation before each step.|
|`cleanWorkingDir` |is a boolean indicating whether the AIs working directory should be erased before starting. This is useful for testing, but if the AI creates a bunch of stuff you might not want to do this.|

## Chat model options
### ChatGPT

| Option  | Description |
| ------- | ----------- |
| `model` | is the OpenAI model to use for the chat endpoint, for example "gpt-3.5-turbo". |
| `max_tokens` | limits the maximum tokens in any given response. |

### FakeGPT

| Option  | Description |
| ------- | ----------- |
| `script`| the script to run |
| `artificialDelaySecs` | adds an artifical delay so you can read the responses rather than it all happening in a blur. |

## Adding commands

The commands that have so far been defined are in the `commands` directory. These are copied to the AIs working directory upon initialisation.

# TODO

0. Save state and resume
1. add `create_commmand` command
2. add `create_function` command
3. add `execute_function` command
4. ChatGPT 3.5 likes to interject text outside of the JSON messages which is annoying and breaks command processing. So the command processing should be less fragile and deal with this in some sane manner.
5. AI also liks to send command sequences in a single message so could create a command queue and handle this.
