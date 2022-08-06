-- https://marta.sh/api/tutorials/your-first-marta-plugin/

plugin {
	id = "de.chris-grieser.sample-plugin",
	name = "Sample Plugin",
	apiVersion = "2.1",
	author = "pseudometa aka Chris Grieser",
	email = "73286100+chrisgrieser@users.noreply.github.com",
	url = "https://chris-grieser.de/"
}

action {
	id = "action",
	name = "Hello world",
	apply = function()
		martax.alert("Hello, world!")
	end
}
