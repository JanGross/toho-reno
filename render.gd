extends Node2D

var counter = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	await $JobServerNode.GetJob()
	await render()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func run_test():
	if counter == 50:
		get_tree().quit()
	render()
	counter += 1

func render():
	print("Rendering frame %s" % counter)
	var tstamp_label = $Placeholder/tstamp
	var tstamp = Time.get_ticks_usec()
	tstamp_label.text = str(tstamp) + "\n %s" % counter
	await RenderingServer.frame_post_draw
	
	# Retrieve the captured image.
	var img = get_viewport().get_texture().get_image()
	
	img.save_png("output/test%s.png" % counter)
