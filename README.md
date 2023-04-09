# summary
The purpose of this project is to see if an LLM (such as chatgpt) can bootstrap itself towards AGI.

Think of it like an AI escape room, where we can test how much the AI can do with basic commands.

In theory the AI only really needs the following commands:

1) File operations (read,write,delete)
2) Run file (and observe output)
3) Ask user for help

It should then be able to create any command it needs, including internet lookup functions.

It would need the ability to ask the user for help because it might need API keys etc or access to paid resources. I suppose a really smart AI would just figure that out by hacking the local system.

It should be able to create all the data structures it needs to keep track of itself.

Aavailable commands are in the "commands" directory, initial prompt is in "initial_prompt.txt"

# TODO

1. add create_commmand command
2. add create_function command
3. add execute_function command
4. make it so the AI can send a command embedded in text
and extract that command if necessary
5. AI also sends command sequences so maybe queue and execute commands if this happens
