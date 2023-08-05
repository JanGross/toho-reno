extends HTTPRequest

func GetRemoteImage(url):
	var image = Image.new()
	print("Fetching remote image %s" % url)
	var urlHash = str(url.hash())
	var outFile = "{dir}/{hash}-{fileName}.png".format({
		'dir': $"/root/Main".cache_dir,
		'hash': urlHash,
		'fileName': url.get_file().rsplit(".", true, 1)[0]
	})

	if FileAccess.file_exists(outFile):
		image.load(outFile)
		print("Loaded image from cache. " + outFile)
		return image
	
	timeout = 1000
	request(url)
	var res = await request_completed
	var magicBytes = res[3].slice(0,8)
	print(magicBytes)
	var fileType = url.get_extension()
	var error = null
	if fileType == "png" or magicBytes == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]):
		print("Detected PNG File")
		error = image.load_png_from_buffer(res[3])
	if ["jpg", "jpeg"].has(fileType) or magicBytes == PackedByteArray([255, 216, 255, 224, 0, 16, 74, 70]):
		print("Detected JPG File")
		error = image.load_jpg_from_buffer(res[3])
	if error != OK:
		print("Error fetching image ", str(error))
		image = load("res://assets/fallback_card.png")
	else:
		image.save_png(outFile)
		print("Saved new image to cache. " + outFile)
	return image
