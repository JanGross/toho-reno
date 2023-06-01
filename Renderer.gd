extends Node2D

var counter = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	"""
	var job = await $JobServer.GetJob()
	var jobHash = str([job["size"], job["elements"]]).sha1_text()
	print("Job hash %s" % jobHash)
	
	var outFile = "output/%s_%s.png" % [job["type"],jobHash]
	if FileAccess.file_exists(outFile):
		print("Skipping, file exists")
		get_tree().quit()
		return
	"""
	
	#DisplayServer.window_set_size(Vector2(job["size"]["width"], job["size"]["height"]))
	#await RenderComposition(job["elements"])
	#await RenderingServer.frame_post_draw
	
	# Get rendered image
	#var img = get_viewport().get_texture().get_image()
	
	#img.save_png(outFile)
	#get_tree().quit()
	
func RenderJob(job):
	print("Rendering ", job["jobId"])
	var renderContainer = $"/root/Main/RenderContainer"
	for node in renderContainer.get_children():
		renderContainer.remove_child(node)
		node.free()
	print("Cleared Render container")
	DisplayServer.window_set_size(Vector2(job["size"]["width"], job["size"]["height"]))
	await RenderComposition(job["elements"])
	await RenderingServer.frame_post_draw
	
	# Get rendered image
	var img = get_viewport().get_texture().get_image()
	var outFile = "%s_%s.png" % [job["type"],job["jobId"]]
	img.save_png("output/" + outFile)
	
	return outFile

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func run_test():
	if counter == 50:
		get_tree().quit()
	render()
	counter += 1
	
func RenderComposition(composition):
	for comp in composition:
		var type = comp["type"]
		if type == "text":
			await RenderLabel(comp)
		if type == "image":
			await RenderImage(comp)

func RenderImage(def):
	var imageNode = TextureRect.new()
	var image = Image.new()
	image = await $"../Remote".GetRemoteImage(def["asset"])
	var texture = ImageTexture.new()
	texture = ImageTexture.create_from_image(image)
	texture.set_size_override(Vector2(def["width"], def["height"]))
	imageNode.texture = texture
	$"/root/Main/RenderContainer".add_child(imageNode)
	
func RenderLabel(def):
	var textNode = Label.new()
	textNode.text = def["text"]
	var pos = Vector2(float(def["x"]), float(def["y"]))
	print("Rendering label '%s' at %s" % [def["text"], pos])

	var labelSettings = LabelSettings.new()
	labelSettings = load("res://DefaultLabelSettings.tres").duplicate()
	
	labelSettings.set("font_size", def["fontSize"])
	textNode.label_settings = labelSettings
	textNode.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	textNode.set_position(pos)
	textNode.set_size(Vector2(float(def["width"]), float(def["height"])))
	textNode.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if "horizontalAlignment" in def:
		var alignments = { "left": HORIZONTAL_ALIGNMENT_LEFT, "right": HORIZONTAL_ALIGNMENT_RIGHT, "center": HORIZONTAL_ALIGNMENT_CENTER, "fill": HORIZONTAL_ALIGNMENT_FILL }
		textNode.horizontal_alignment = alignments[def["horizontalAlignment"]]
		
	$"/root/Main/RenderContainer".add_child(textNode)
	
func render():
	print("Rendering frame %s" % counter)
	var tstamp_label = $"../Placeholder/tstamp"
	var tstamp = Time.get_ticks_usec()
	tstamp_label.text = str(tstamp) + "\n %s" % counter
	await RenderingServer.frame_post_draw
	
	# Retrieve the captured image.
	var img = get_viewport().get_texture().get_image()
	
	img.save_png("output/test%s.png" % counter)
