library(rvest)
library(xml2)

# this function splits the long_text into chunks
# with maximum size chunk_size. But it tries to do
# this sensibly and break on newlines rather than
# randomly
split_long_text <- function(long_text, chunk_size) {
   textLen <- nchar(long_text)
   # if already small, we don't need to do anything
   if(textLen<chunk_size) {
      return(long_text)
   }

   # otherwise we look for newlines and split on them
   # if possible, if there is a contiguous length
   # of text longer than the chunk_size without a newline
   sections <- list()
   splitPos <- 0
   while(textLen>chunk_size) {
      # find the newlines
      newlineLocs <- unlist(gregexpr("\n",long_text))
      if(min(newlineLocs)>chunk_size) {
         lastNewline <- -1
      } else {
         # find the last newline at a pos < chunk_size
         lastNewline <- max(newlineLocs[newlineLocs<chunk_size])
      }
      # if no nl was found we need to split another way
      if(lastNewline==-1) {
         # try and split on space
         spaceLocs <- unlist(gregexpr(" ",long_text))
         lastSpaceLoc <- max(spaceLocs[spaceLocs<chunk_size])
         # if can't split on space, just split
         if(lastSpaceLoc==-1) {
            splitPos <- chunk_size
         } else {
            splitPos <- lastSpaceLoc
         }

      } else {
         splitPos <- lastNewline
      }

      # otherwise split on the newline
      section <- substring(long_text,0,splitPos-1)
      # add the section
      sections <- c(sections,section)

      # continue with the remainder of the text
      long_text <- substring(long_text,splitPos+1)
      textLen <- nchar(long_text)
   }

   sections
}


summarize_long_text <- function(prompt, total_max_tokens = 2048, chunk_size = 2048) {
   # Calculate the number of chunks (N)
   N <- ceiling(nchar(prompt) / chunk_size)

   # Divide the total_max_tokens by the number of chunks
   chunk_max_tokens <- floor(total_max_tokens / N)

   # Split the text into smaller sections
   text_sections <- split_long_text(prompt,chunk_size)

   # Initialize an empty string to store the combined summary
   combined_summary <- ""

   # Itetrate through text_sections and summarize each section
   # Spawn a new agent
   agentID <- agentManager$spawnAgent(max_tokens=chunk_max_tokens)
   nSections <- length(text_sections)
   sectionCount <- 1
   # XXX do this in parallel
   for (section in text_sections) {

      # Request a summary for the current section
      msg <- list(
         from="W0",
         to=agentID,
         action="chat",
         msg=paste("Please summarize the following text, try and reduce the length by at least two thirds:", section)
      )
      summary <- agentManager$syncChat(msg)
      print(paste0("Summarizing text ",sectionCount,"/",nSections))
      sectionCount <- sectionCount + 1

      # roll back the agent's messages so it can be used again
      agentManager$resetMessages(agentID)

      # Append the summary to the combined_summary
      combined_summary <- paste(combined_summary, summary)
   }
  
   # ask the AI to summarize the combined_summary so
   # it is coherent
   msg <- list(
      from="W0",
      to=agentID,
      action="chat",
      msg=paste("Please summarize the following text, try and reduce the length by at least two thirds:", combined_summary)
   )
   summary <- agentManager$syncChat(msg)

   agentManager$deleteAgent(agentID)

   return(summary)
}


extract_content <- function(text) {
  # Create an XML object from the input text
  html_obj <- read_html(text)

  # Remove all comments from the HTML
  html_obj %>% html_nodes(xpath = "//comment()") %>% xml_remove()

  # Extract text nodes, <code> nodes, <pre> nodes, and <math> nodes that do not have any ancestors that are <script>, <style>, or <!--comment-->
  selected_nodes <- html_obj %>% html_nodes(xpath = "//*[not(self::script) and not(self::style) and not(ancestor::comment())]/text() | //code | //pre | //math")

  # Convert the list of nodes to text
  text_content <- sapply(selected_nodes, function(node) {
    node_name <- node %>% xml_name()
    if (node_name == "math") {
      # Preserve MathML structure
      as.character(node)
    } else if (node_name == "code" || node_name == "pre") {
      # Preserve the original formatting for <code> and <pre> nodes
      html_text(node, trim = FALSE)
    } else {
      # Extract text for other nodes
      html_text(node, trim = TRUE)
    }
  })

  # Combine the extracted text lines
  text_content <- paste(text_content, collapse = " ")

  return(text_content)
}

command_read_from_url <- list(
  active = T,
  author = "human and AI",
  usage = list(
      action="read_from_url",
      url="url",
      chatgpt_summarize="true/false",
      comment="Reads the contents of the specified URL. If chatgpt_summarize is true, new chatgpt agents will be spawned (as necessary) to summarize the contents and this summary will be returned rather than the raw content."
   ),

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
         summary <- summarize_long_text(clean_content,total_max_tokens=500,chunk_size=1500)
        return(summary)
      } else {
        return(clean_content)
      }
    } else {
      #return(toJSON(error_json, auto_unbox = TRUE))
		list(error = "Error: Failed to fetch the content from the specified URL.")
    }
  }
)


# test
#t1 <- paste0(readLines("data/test/test.html"),collapse="\n")
#t2 <- paste0(readLines("data/test/test2.html"),collapse="\n")
#t1x <- extract_content(t1)
#t2x <- extract_content(t2)
