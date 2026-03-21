extends AcceptDialog

var track_name: String
var folder_name: String

func _ready():
	add_button("Show Render", true, 'show_render')


func _on_custom_action(action):
	if action == 'show_render':
		var path = Data.renders_dir.path_join(track_name).path_join(folder_name)
		var global_path = ProjectSettings.globalize_path(path)
		OS.shell_show_in_file_manager(global_path, false)
		hide()
