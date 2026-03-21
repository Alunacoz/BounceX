extends VideoStreamPlayer

func load_video(file_path: String) -> bool:
	var stream := FFmpegVideoStream.new()
	stream.file = file_path
	self.stream = stream
	# play+stop triggers FFmpeg open_file() so duration becomes available
	play()
	stop()
	return get_stream_length() > 0.0


func scrub_to(normalized_t: float) -> void:
	var pos := normalized_t * get_stream_length()
	set_stream_position(pos)
