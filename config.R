config <- list(
	#chatType="fakegpt",
	chatType="chatgpt",
	aiName="test0",
	runtimeDirPrefix="runtime",
	initialPrompt="agi_prompt_v0.1.txt",
	continuous=F,
	cleanWorkingDir=T,

	# ChatGPT options
	chatgpt = list(
		model = "gpt-3.5-turbo",
		max_tokens = 512,
		temperature = 0.7
	),

	# FakeGPT options
	fakegpt = list(
		script = "read_and_write_file_test",
		artificialDelaySecs = 1
	)

	# Vicuna
)
