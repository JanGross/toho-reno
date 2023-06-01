extends Node2D

var config = ConfigFile.new()

var websocket_url
var public_path
var rendering = false
signal finished_rendering

# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("res://config.cfg")
	websocket_url = config.get_value("core", "websocket_url")
	public_path = config.get_value("core", "public_path")
	
	print("Starting render node")
	$JobServer.InitWebsocket()

func FinishedRendering():
	rendering = false
