config <- list(
	chatType="fakegpt",
	#chatType="chatgpt",
	aiName="test1",
	runtimeDirPrefix="runtime",
	initialPrompt="agi_prompt_v0.1.txt",
	continuous=F,
	cleanWorkingDir=T,
	trackTokens=F, # not implemented yet, but leave here

	# commands available to AI
	commandEncoding = "JSON",
	commands = list(
		"list_commands",
		"chat_with_agent"
	),

	# ChatGPT options
	chatgpt = list(
		model = "gpt-3.5-turbo-0301",
		max_tokens = 512,
		temperature = 0.7
	),

	# FakeGPT options
	fakegpt = list(
		script = "chat_test",
		artificialDelaySecs = 1
	)

	# Vicuna
)
