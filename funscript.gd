class_name Funscript

static func export(marker_data: Dictionary, path_meta: Dictionary, out_path: String, invert: bool, duration: int = 0) -> void:
	var actions := []
	var sorted_frames := marker_data.keys()
	sorted_frames.sort()
	for frame in sorted_frames:
		var marker: Array = marker_data[frame]
		var at := int(frame * (1000.0 / 60.0))
		var pos := clampi(int(round(marker[0] * 100.0)), 0, 100)
		actions.append({"at": at, "pos": pos})
	
	var funscript := {
		"version": "1.0",
		"inverted": invert,
		"range": 100,
		"actions": actions,
		"metadata": {
			"creator": path_meta.get("path_creator", ""),
			"title": path_meta.get("related_media", ""),
			"description": "",
			"duration": duration if duration > 0 else int(round(sorted_frames.back() / 60.0)),
			"license": "",
			"notes": "Exported from BounceX",
			"performers": [],
			"script_url": "",
			"tags": [],
			"type": "basic",
			"video_url": ""
		}
	}
	
	var file := FileAccess.open(out_path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(funscript))
		file.close()
