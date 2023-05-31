extends HTTPRequest

func GetJob():
	print("Fetching Job")
	request("http://127.0.0.1:8000/template.json")
	var res = await request_completed
	var json = JSON.parse_string(res[3].get_string_from_utf8())
	return json
