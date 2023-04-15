echo $1
exit
# command to return how many tokens a message consumes
out=`curl \
	 -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{
        \"model\": \"gpt-3.5-turbo\",
        \"messages\": [
            {\"role\": \"system\", \"content\": \"$1\"}
        ],
        \"max_tokens\": 1024,
        \"temperature\": 0.7
    }" \
    "https://api.openai.com/v1/chat/completions"`

response=`echo $out | jq .choices[0].message.content`
prompt_tokens=`echo $out | jq .usage.prompt_tokens`
response_tokens=`echo $out | jq .usage.completion_tokens`

echo Prompt: "$1" \($prompt_tokens tokens\)
echo Response: $response \($response_tokens tokens\)
