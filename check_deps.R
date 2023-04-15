# install required packages
installed_packages <- row.names(installed.packages())
if(!"renv" %in% installed_packages) {
	print(paste0("installing renv for dependency lister"))
	install.packages("renv")
}
library(renv)
required_packages <- dependencies()$Package
	
lapply(required_packages,function(p) {
	if(!p %in% installed_packages) {
		print(paste0("Installing ",p))
		install.packages(p)
	}
})

# check user has set API key for OPENAI
if(nchar(Sys.getenv("OPENAI_API_KEY"))==0) {
	print("OPENAI_API_KEY is not defined in your local environment, cannot run.")
	print("Please fix errors mentioned above and try again")
	stop()
}

if(nchar(Sys.getenv("GOOGLE_API_KEY"))==0) {
	warning("GOOGLE_API_KEY not set, you will not be able to use google search command")
}

# check user has set API key for google search
if(nchar(Sys.getenv("GOOGLE_SEARCH_ENGINE"))==0) {
	warning("GOOGLE_SEARCH_ENGINE not set, you must create a custom search engine to use google search")
}
