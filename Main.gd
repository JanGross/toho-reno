extends Node2D

var config = ConfigFile.new()

var websocket_url
var public_path
var output_dir
var auth_key
var rendering = false
signal finished_rendering

# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("res://config.cfg")
	websocket_url = config.get_value("core", "websocket_url")
	public_path = config.get_value("core", "public_path")
	output_dir = config.get_value("core", "output_dir")
	auth_key = config.get_value("core", "auth_key")
	print("Starting render node")
	
	var directory = DirAccess.open(".")
	directory.make_dir(output_dir)
	$JobServer.InitWebsocket()

func FinishedRendering():
	rendering = false
