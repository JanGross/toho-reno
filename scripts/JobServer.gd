extends HTTPRequest

var socket = WebSocketPeer.new()

var client_id
var connected = false
func InitWebsocket():
	print("Connecting websocket ")
	socket.max_queued_packets = 32768
	socket.outbound_buffer_size = 5000000
	socket.connect_to_url($"/root/Main".websocket_url, TLSOptions.client_unsafe())
	var timeout = 5
	while socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		socket.poll()
		await get_tree().create_timer(.25).timeout
		timeout -= 0.25
		if timeout <= 0:
			timeout = 5
			socket.connect_to_url($"/root/Main".websocket_url, TLSOptions.client_unsafe())
		
	var init_message = {
		"register": {
			"version": 1,
			"auth_key": $"/root/Main".auth_key,
			"hostname": $"/root/Main".hostname
		}
	}
	socket.send_text(str(init_message))
	connected = true
	print("Connected")
	while connected:
		await PollWebsocket()
		RenderingServer.force_draw()
		DisplayServer.process_events()
		await get_tree().create_timer(0.1).timeout
	

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
				client_id = json["welcome"]["clientId"]
			if "job" in json:
				var job = json["job"]
				print("Recevied Job ", job["jobId"])
				main.rendering = true
				
				var result_path = await $"../Renderer".RenderJob(job)
				var result_value = ""
				var result_type = "URL" if $"/root/Main".serve_mode == "local" else "B64:PNG"
				if $"/root/Main".serve_mode == "local":
					result_value = result_path
				if $"/root/Main".serve_mode == "remote":
					print("trying to open " + result_path)
					var resut_file = FileAccess.open(result_path,FileAccess.READ)
					result_value = "{path}:{data}".format({
						"path": result_path.get_file(),
						"data": Marshalls.raw_to_base64(resut_file.get_buffer(resut_file.get_length()))
						})
				var debugFile = FileAccess.open("user://debug.log", FileAccess.WRITE)
				debugFile.store_string(result_value)
				debugFile.flush()
				debugFile.close()
				var response = {
					"result": {
						"type": result_type,
						"jobId": job["jobId"],
						"value": result_value
					}
				}
				print("[%s] Sending result via wss..." % str(response).length())
				var time_start = Time.get_unix_time_from_system()
				socket.send_text(str(response))
				var time_elapsed = Time.get_unix_time_from_system() - time_start
				print("Sent result in %s \n" % time_elapsed, result_path)
				main.rendering = false
	elif state == WebSocketPeer.STATE_CLOSING:
		socket.poll()
	elif state == WebSocketPeer.STATE_CLOSED:
		print(socket.get_packet())
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		print("Attempting reconnect in 5")
		set_process(false) # Stop processing.
		connected = false
		await get_tree().create_timer(5).timeout
		InitWebsocket()
		
func _process(_delta):
	pass
		

