extends HTTPRequest

func GetRemoteImage(url):
	print("Fetching remote image %s" % url)
	request(url)
	var res = await request_completed
	var image = Image.new()
	image.load_png_from_buffer(res[3])
	return image
