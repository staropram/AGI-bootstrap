script_spawn_agent_test = list(
	list(from="a0",action="spawn_agent",max_tokens="300",comment="spawning a new agent"),
	list(from="a0",to="a1",action="chat",msg="what is the heaviest fruit?"),
	list(from="a0",to="a1",action="chat",msg="but is it tasty?"),
	list(from="a0",action="exit")
)
