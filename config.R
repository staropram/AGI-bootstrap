config <- list(
	chatType="fakegpt",
	aiName="test0",
	root="/home/ash/agi",
	runtimeDirPrefix="runtime",
	initialPrompt="agi_prompt_v0.1.txt",

	# ChatGPT options
	chatgpt = list(
		model = "gpt-3.5-turbo",
		max_tokens = 1024
	),

	# FakeGPT options
	fakegpt = list(
		script = "create_file_test"
	)

	# Vicuna
)
