extends HTTPRequest


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func GetJob():
	request_completed.connect(_on_request_completed)
	request("https://raw.githubusercontent.com/JanGross/job-server/master/jobDefinition.json")
	await request_completed

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	for comp in json["composition"]:
		var type = comp["type"]
		if type == "text":
			var textNode = Label.new()
			textNode.text = comp["text"]
			var pos = Vector2(float(comp["x"]), float(comp["y"]))
			print("Rendering label at %s" % pos)
			textNode.set_position(pos)
			textNode.set_size(Vector2(float(comp["width"]), float(comp["height"])))
			get_tree().get_root().add_child(textNode)
