extends HTTPRequest

func GetRemoteImage(url):
	var image = Image.new()
	print("Fetching remote image %s" % url)
	request(url)
	var res = await request_completed
	var magicBytes = res[3].slice(0,8)
	print(magicBytes)
	var error = null
	if magicBytes == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]):
		print("Detected PNG File")
		error = image.load_png_from_buffer(res[3])
	if magicBytes == PackedByteArray([255, 216, 255, 224, 0, 16, 74, 70]):
		print("Detected JPG File")
		error = image.load_jpg_from_buffer(res[3])
	if error != OK:
		print("Error fetching image ", str(error))
	return image
