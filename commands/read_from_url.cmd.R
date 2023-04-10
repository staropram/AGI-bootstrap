library(rvest)
library(xml2)

extract_content <- function(text) {
  # Create an XML object from the input text
  html_obj <- read_html(text)

  # Remove all comments from the HTML
  html_obj %>% html_nodes(xpath = "//comment()") %>% xml_remove()

  # Extract the text content without HTML tags
  text_content <- html_obj %>% html_nodes(xpath = "//*[not(self::script) and not(self::style)]/text()") %>% html_text(trim = TRUE)

  # Combine the extracted text lines
  text_content <- paste(text_content, collapse = "\n")

  return(text_content)
}

command_read_from_url <- list(
  active = T,
  author = "human",
  usage = '{"action":"read_from_url","url":"url","comment","chatgpt_summarize":"true/false",:"Reads the contents of the specified URL. If chatgpt_summarize is true, a new chatgpt agent will be spawned to summarize the contents and this summary will be returned rather than the raw content."}',

  f = function(args) {
    url <- args$url
    chatgpt_summarize <- args$chatgpt_summarize

    # Retrieve the content from the URL
    response <- GET(url)

    # Check if the request was successful
    if (http_status(response)$category == "Success") {
      content <- content(response, as = "text")

      # Extract the text content
      clean_content <- extract_content(content)

      # If chatgpt_summarize is TRUE, send the content to a ChatGPT agent for summarization
      if (chatgpt_summarize) {
        prompt <- paste("Summarize the following text, aim to make the summary at least half the length of the original text:", clean_content)
			# spawn a new agent
			agentManager$spawnAgent(id="webagent",max_tokens=2048)
			summary <- agentManager$chatWithAgent("webagent",prompt)
        return(summary)
      } else {
        return(clean_content)
      }
    } else {
      error_json <- list(error = "Error: Failed to fetch the content from the specified URL.")
      return(toJSON(error_json, auto_unbox = TRUE))
    }
  },

  # print the message
  printMsg = function(msg) {
		print_action(msg$action)
		print_param("url",msg$url)
		print_param("chatgpt_summarize",msg$chatgpt_summarize)
		print_comment(msg$comment)
  }
)
