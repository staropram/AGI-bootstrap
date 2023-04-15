script_read_and_write_file_test <- list(
	list(action="write_file", fn="test.txt",content="Testing testing 123\ntesting 123",comment="Creating a file with test content"),
	list(action="read_file", fn="test.txt",comment="Reading the content back in"),
	list(action="exit")
)
