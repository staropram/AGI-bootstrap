script_download_file_test <- list(
	list(action="download_file", url="https://raw.githubusercontent.com/staropram/AGI-bootstrap/master/data/test/testfile.txt",fn="testfile.txt",comment="Downloading an existing file"),
	list(action="read_file", fn="testfile.txt",comment="Reading the content back in"),
	list(action="download_file", url="https://raw.githubusercontent.com/staropram/AGI-bootstrap/master/data/test/notexist.txt",fn="nofiletest.txt",comment="Downloading bogus URL"),
	list(action="exit")
)
