extends HTTPRequest

var socket = WebSocketPeer.new()

func InitWebsocket():
	print("Connecting websocket ")
	var i = 0
	while socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		socket.connect_to_url($"/root/Main".websocket_url, TLSOptions.client_unsafe())
		socket.poll()
		
		
	socket.send_text(str({"register": 1}))
	print("Connected")
	while true:
		await PollWebsocket()
	

func PollWebsocket():
	var main = $"/root/Main"
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet()
			var json = JSON.parse_string(packet.get_string_from_utf8())
			print("Packet: ", packet.slice(0,5), "...")
			if "welcome" in json:
				print("Registered as client %s" % json["welcome"]["clientId"])
			if "job" in json:
				var job = json["job"]
				print("Recevied Job ", job["jobId"])
				main.rendering = true
				var result = await $"../Renderer".RenderJob(job)
				var response = {
					"result": {
						"jobId": job["jobId"],
						"path": $"/root/Main".public_path + result
					}
				}
				socket.send_text(str(response))
				print("Sent result ", result)
				main.rendering = false
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		print("Attempting reconnect in 10")
		set_process(false) # Stop processing.
		await get_tree().create_timer(10).timeout
		InitWebsocket()
		
func _process(_delta):
	pass
		

