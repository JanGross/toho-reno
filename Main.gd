extends Node2D

var config = ConfigFile.new()

var websocket_url
var public_path
var output_dir
var serve_mode
var cache_dir
var auth_key
var hostname
var rendering = false
signal finished_rendering

# Called when the node enters the scene tree for the first time.
func _ready():
	config.load("res://config.cfg")
	websocket_url = config.get_value("core", "websocket_url")
	public_path = config.get_value("core", "public_path")
	output_dir = config.get_value("core", "output_dir")
	serve_mode = config.get_value("core", "serve_mode")
	cache_dir = config.get_value("core", "cache_dir")
	auth_key = config.get_value("core", "auth_key")
	hostname = config.get_value("core", "hostname")
	
	if OS.has_environment("USERNAME"):
		hostname = "%s/%s" % [OS.get_environment("USERNAME"), hostname]
	else:
		hostname = "%s/%s" % [OS.get_name(), hostname]
	
	print("Starting render node")
	
	DirAccess.make_dir_absolute(output_dir)
	DirAccess.make_dir_absolute(cache_dir)
	$JobServer.InitWebsocket()

func FinishedRendering():
	rendering = false
