# Load required packages
library(httr)
library(jsonlite)

# Define function to search Google
google_search <- function(query, start, num) {
  # Set API endpoint and parameters
  endpoint <- "https://www.googleapis.com/customsearch/v1"
  params <- list(
    q = query,
    start = start,
    num = num,
    cx = Sys.getenv("GOOGLE_SEARCH_ENGINE"),
    key = Sys.getenv("GOOGLE_API_KEY")
  )
  
  # Make GET request to API
  res <- GET(endpoint, query = params)
  
  # Parse JSON response
  content <- content(res, "text")
  content <- fromJSON(content)
  
  # Extract search results
  results <- content$items
  return(results)
}

# Define function to format Google search results
format_google_results <- function(results) {
  output <- '{ "results":['
  for (i in 1:nrow(results)) {
    output <- paste0(output, '{"title":"',results$title[i],',"link" :"',results$link[i],'"}')
  	if(i!=nrow(results)) {
		output <- paste0(output,",")
	}
  }
	output <- paste0(output,']}')
  return(output)
}

# Define command for AGI to perform Google search
command_google_search <- list(
  active = T,
  author = "AI",
  usage = '{"action":"google_search","query":"search_query","start":1,"num":10,"comment":"Performs a Google search for the specified query and returns up to the specified number of results, starting from the specified index."}',
  f = function(args) {
    # Call Google search function
    results <- google_search(args$query, args$start, args$num)
    
    # Format search results
    output <- format_google_results(results)
    
    return(paste0('{"status":"ok","output":"',output,'"}'))
  },

  # Print the message
   printMsg = function(msg) {
      print_action(msg$action)
      print_param("query",msg$query)
      print_param("start",msg$start)
      print_param("num",msg$num)
		print_comment(msg$comment)
  }
)

# Usage example:
# {
#   "action": "google_search",
#   "query": "my search query",
#   "start": 1,
#   "num": 10,
#   "comment": "Performing a Google search for the specified query and returning up to the specified number of results, starting from the specified index."
# }
