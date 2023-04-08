config <- list(
	chatType="fakegpt",
	name="test0",
	workingDirPrefix="runtime",

	# ChatGPT options
	chatgpt <- list(
		model = "gpt-3.5-turbo",
		max_tokens = 1024
	),

	# FakeGPT options
	fakegpt <- list(
		# in this case the model is the script
		model = "create_file_test"
	)

	# Vicuna
)
