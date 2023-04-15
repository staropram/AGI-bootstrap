script_create_file_test <- list(
	list(action="list_commands",comment="getting list of commands to build my AGI"),
	list(action="show_command_source",command_name="list_commands",comment="Examining list_commands source code"),
	list(action="write_file",fn="test.R",content="testFunction <- function() list( print(\"Cool\") )\ntestFunction()",commment="Writing a simple test function"),
	list(action="source_r_file",fn="test.R",comment="calling simple test function"),
	list(action="exit")
)
