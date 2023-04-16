config <- list(
	chatType="fakegpt",
	#chatType="chatgpt",
	aiName="test0",
	runtimeDirPrefix="runtime",
	#initialPrompt="agi_prompt_v0.1.txt",
	initialPrompt="agi_prompt_alt_1.txt",
	continuous=T,
	cleanWorkingDir=T,
	trackTokens=F, # not implemented yet, but leave here

	# commands available to AI
	commandEncoding = "JSON",
	commands = list(
		"exit",
		"list_commands",
		"chat",
		"spawn_agent",
		"show_command_source",
		"write_file",
		"source_r_file",
		# "google_search", # enable with care, burns tokens
		# "read_from_url", # enable with care, burns tokens
		"list_files",
		"read_file"
	),

	# ChatGPT options
	chatgpt = list(
		model = "gpt-3.5-turbo-0301",
		max_tokens = 512,
		temperature = 0.7
	),

	# FakeGPT options
	fakegpt = list(
		#script = "spawn_agent_test",
		#script = "google_search_test",
		#script = "create_file_test",
		#script = "list_files_test",
		#script = "read_and_write_file_test",
		#script = "invalid_commands_test",
		script = "read_from_url_test",
		artificialDelaySecs = 1
	)

	# Vicuna
)
