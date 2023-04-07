The purpose of this is to see if an LLM (such as chatgpt4) can bootstrap itself towards AGI.

It is an interesting experiment to see what it will do given the tools.

In theory bootstrap only really needs the following commands:

1) file operations (read,write,delete)
2) run file (and observe output)
3) create command (that it can use, which just runs the program it creates from 1 and 2)
4) ask user for help

It should then be able to create any command it needs, including internet lookup functions.

It has the ability to ask user for help because it might need API keys etc or access to paid resources.

It should be able to create all the data structures it needs to keep track of itself.
