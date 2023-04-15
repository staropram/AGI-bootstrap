script_invalid_commands_test <- list(
	list(action="exit"),
	list(action="nonexistent",comment="Sending a BS message to trip you up"),
	list(action="show_command_source",comment="valid command but missing parameter"),
	list(action="chat",from="a0",to="nonexist",msg="hello",comment="trying to talk to a non-existent agent"),
	list(action="chat",from="impersonator",to="h0",msg="hello",comment="identifying as a non-existent agent"),
	list(action="chat",from="h0",to="h0",msg="hello",comment="impersonating h0")
)
