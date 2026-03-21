extends VBoxContainer

var selected: Node

func _on_color_picker_color_changed(color):
	match $TabBar.current_tab:
		0:
			owner.toggle_ball_visible(true)
			selected.set_self_modulate(color)
		2:
			selected.set_self_modulate(color)
		1:
			selected.set_self_modulate(color)
			%Markers.get_node('Line').set_self_modulate(color)
			change_path_color(color)
		3:
			selected.set_self_modulate(color)
			owner.top_color = color
		4:
			selected.set_self_modulate(color)
			owner.top_color_active = color
		5:
			selected.set_self_modulate(color)
			owner.bottom_color = color
		6:
			selected.set_self_modulate(color)
			owner.bottom_color_active = color
		7:
			owner.toggle_ball_visible(true)
			selected.set_self_modulate(color)
			owner.hold_breath_ball_color = color
		8:
			change_path_color(color)
			owner.hold_breath_path_color = color
	var title = $TabBar.get_tab_title($TabBar.current_tab)
	Data.set_config('colors', title, color)


func _on_tab_bar_tab_changed(tab):
	var selected_color: Color
	match tab:
		0:
			selected = owner.get_node('Ball')
			selected_color = selected.self_modulate
		1:
			selected = owner.get_node('Path')
			selected_color = selected.self_modulate
		2:
			selected = owner.get_node('Backdrop')
			selected_color = selected.self_modulate
		3:
			selected = owner.get_node('TopLine')
			selected_color = owner.top_color
		4:
			selected = owner.get_node('TopLine')
			selected_color = owner.top_color_active
		5:
			selected = owner.get_node('BottomLine')
			selected_color = owner.bottom_color
		6:
			selected = owner.get_node('BottomLine')
			selected_color = owner.bottom_color_active
		7:
			selected = owner.get_node('Ball')
			selected_color = owner.hold_breath_ball_color
		8:
			selected = owner.get_node('Path')
			selected_color = owner.hold_breath_path_color
	$ColorPicker.color = selected_color


func change_path_color(input_color: Color):
	owner.get_node('Path').self_modulate = input_color
	for node in get_tree().get_nodes_in_group('lines'):
		node.set_self_modulate(input_color)


func _on_done_pressed():
	hide()


func _on_visibility_changed():
	if not is_visible_in_tree():
		var ball_color = Data.config.get_value('colors', 'Ball', Color.WHITE)
		var path_color = Data.config.get_value('colors', 'Path', Color.WHITE)
		owner.get_node('Ball').self_modulate = ball_color
		owner.toggle_ball_visible(false)
		change_path_color(path_color)
		%Options.show()
