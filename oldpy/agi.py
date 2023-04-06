import openai
import os
import subprocess
import json
import pdb

# Replace with your OpenAI API key
openai.api_key = os.environ["OPENAI_API_KEY"]

g_messages = []

def chat(prompt):
    g_messages.append({"role": "user","content":prompt})
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages = g_messages,
        #temperature=0.5,
        max_tokens=300,
        #top_p=1,
        #frequency_penalty=0,
        #presence_penalty=0
    )

    return response.choices[0].message.content

def write_file(file_name, content):
    with open(file_name, "w") as f:
        f.write(content)

def execute_command(command):
    try:
        output = subprocess.check_output(command, shell=True, text=True)
        print(f"Command output:\n{output}")
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")

def read_commands_file(file_name):
    with open(file_name, 'r') as file:
        commands = json.load(file)
    return commands

def list_commands():
    commands = read_commands_file("commands.json")
    command_list = ""
    for command in commands:
        command_list += f"{command['name']}: {command['description']}\n"
    return command_list.strip()

def describe_command(command_name):
    commands = read_commands_file()
    for command in commands:
        if command["name"] == command_name:
            description = f"Name: {command['name']}\n"
            description += f"Description: {command['description']}\n"
            description += f"Example: {json.dumps(command['example'], indent=2)}"
            return description
    return f"Command '{command_name}' not found."

def read_prompt_file(file_name):
    with open(file_name, "r") as f:
        prompt = f.read().strip()
    return prompt

def handle_json_command(json_command):
    action = json_command.get("action")

    if action == "write_file":
        file_name = json_command.get("file_name")
        content = json_command.get("content")
        write_file(file_name, content)
        print(f"File {file_name} has been created.")
    elif action == "list_commands":
        return list_commands()
    elif action == "describe_command":
        command_name = json_command.get("command_name")
        if command_name:
            return describe_command(command_name)
        else:
            return "Missing 'command_name' parameter in 'describe_command' action."
    else:
        return("Invalid action in JSON command.")

def main():
    print("Welcome to the AGI bootstrap!")
    print(openai.api_key)
    initial_prompt = read_prompt_file("initial_prompt.txt")
    chatgpt_response = chat(initial_prompt)

    while True:
        print(chatgpt_response)
        user_input = input("Do you wish to continue?")
        if user_input=="n":
            break

        if user_input.lower() == "exit":
            print("Exiting AGI bootstrap...")
            break

        try:
            json_command = json.loads(chatgpt_response)
            command_response = handle_json_command(json_command)
            g_messages.append({"role":"assistant","content":command_response})
            pdb.set_trace()
            chatgpt_response = chat(command_response)
        except json.JSONDecodeError as e:
            print(f"Invalid JSON input: {e}")


if __name__ == "__main__":
    main()

