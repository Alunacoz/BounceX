extends AcceptDialog

const ACTIONS: Array = [
	["record",      "Toggle Record"],
	["play",        "Play/Pause"],
	["menu",        "Toggle Menu"],
	["go_to_start", "Go to Start"],
	["depth_0",     "Depth 0"],
	["depth_1",     "Depth 1"],
	["depth_2",     "Depth 2"],
	["depth_3",     "Depth 3"],
	["depth_4",     "Depth 4"],
	["depth_5",     "Depth 5"],
	["depth_6",     "Depth 6"],
	["depth_7",     "Depth 7"],
	["depth_8",     "Depth 8"],
	["depth_9",     "Depth 9"],
	["depth_10",    "Depth 10"],
]

const BUTTON_NAMES: Dictionary = {
	JOY_BUTTON_A:              "A",
	JOY_BUTTON_B:              "B",
	JOY_BUTTON_X:              "X",
	JOY_BUTTON_Y:              "Y",
	JOY_BUTTON_LEFT_SHOULDER:  "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_LEFT_STICK:     "L3",
	JOY_BUTTON_RIGHT_STICK:    "R3",
	JOY_BUTTON_BACK:           "Back",
	JOY_BUTTON_START:          "Start",
	JOY_BUTTON_DPAD_UP:        "D-Up",
	JOY_BUTTON_DPAD_DOWN:      "D-Down",
	JOY_BUTTON_DPAD_LEFT:      "D-Left",
	JOY_BUTTON_DPAD_RIGHT:     "D-Right",
}

const PS_BUTTON_NAMES: Dictionary = {
	JOY_BUTTON_A:              "Cross",
	JOY_BUTTON_B:              "Circle",
	JOY_BUTTON_X:              "Square",
	JOY_BUTTON_Y:              "Triangle",
	JOY_BUTTON_LEFT_SHOULDER:  "L1",
	JOY_BUTTON_RIGHT_SHOULDER: "R1",
	JOY_BUTTON_LEFT_STICK:     "L3",
	JOY_BUTTON_RIGHT_STICK:    "R3",
	JOY_BUTTON_BACK:           "Share",
	JOY_BUTTON_START:          "Options",
	JOY_BUTTON_DPAD_UP:        "D-Up",
	JOY_BUTTON_DPAD_DOWN:      "D-Down",
	JOY_BUTTON_DPAD_LEFT:      "D-Left",
	JOY_BUTTON_DPAD_RIGHT:     "D-Right",
}

const AXIS_NAMES: Dictionary = {
	JOY_AXIS_LEFT_X:        ["LS ←",  "LS →"],
	JOY_AXIS_LEFT_Y:        ["LS ↑",  "LS ↓"],
	JOY_AXIS_RIGHT_X:       ["RS ←",  "RS →"],
	JOY_AXIS_RIGHT_Y:       ["RS ↑",  "RS ↓"],
	JOY_AXIS_TRIGGER_LEFT:  ["",      "L2"],
	JOY_AXIS_TRIGGER_RIGHT: ["",      "R2"],
}

var _listening_action: String = ""
var _listening_button: Button = null
var _rows_data: Dictionary = {}  # action -> {"chips": HBoxContainer, "add": Button}


func _ready() -> void:
	title = "Gamepad Remapping"
	_build_header()
	_build_rows()
	$VBox/ResetAll.pressed.connect(_on_reset_pressed)
	about_to_popup.connect(_refresh_all_bindings)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _build_header() -> void:
	var header := HBoxContainer.new()
	header.set('theme_override_constants/separation', 20)

	var dz_lbl := Label.new()
	dz_lbl.text = "Deadzone"
	dz_lbl.custom_minimum_size.x = 70
	dz_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var action_lbl := Label.new()
	action_lbl.text = "Action"
	action_lbl.custom_minimum_size.x = 130

	var bindings_lbl := Label.new()
	bindings_lbl.text = "Bindings"
	bindings_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	header.add_child(dz_lbl)
	header.add_child(action_lbl)
	header.add_child(bindings_lbl)

	var separator := HSeparator.new()

	$VBox.add_child(header)
	$VBox.move_child(header, 0)
	$VBox.add_child(separator)
	$VBox.move_child(separator, 1)


func _refresh_all_bindings() -> void:
	_cancel_listening()
	for entry in ACTIONS:
		var action: String = entry[0]
		_rebuild_chips(action)
		_rows_data[action]["dz"].value = InputMap.action_get_deadzone(action)


func _build_rows() -> void:
	var container := $VBox/Scroll/Rows
	for entry in ACTIONS:
		var action:  String = entry[0]
		var display: String = entry[1]

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_FILL
		row.set('theme_override_constants/separation', 20)
		row.focus_mode = 0

		var dz_spin := SpinBox.new()
		dz_spin.min_value = 0.0
		dz_spin.max_value = 1.0
		dz_spin.step = 0.05
		dz_spin.custom_minimum_size.x = 70
		dz_spin.value = InputMap.action_get_deadzone(action)
		dz_spin.value_changed.connect(_on_deadzone_changed.bind(action))

		var name_lbl := Label.new()
		name_lbl.text = display
		name_lbl.custom_minimum_size.x = 130
		name_lbl.focus_mode = 0

		var chips := HBoxContainer.new()
		chips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chips.set('theme_override_constants/separation', 10)
		chips.focus_mode = 0

		var add_btn := Button.new()
		add_btn.text = "+"
		add_btn.custom_minimum_size.x = 28
		add_btn.pressed.connect(_on_add_pressed.bind(action, add_btn))
		add_btn.focus_mode = 0

		row.add_child(dz_spin)
		row.add_child(name_lbl)
		row.add_child(chips)
		row.add_child(add_btn)
		container.add_child(row)
		_rows_data[action] = {"chips": chips, "add": add_btn, "dz": dz_spin}


func _rebuild_chips(action: String) -> void:
	var chips: HBoxContainer = _rows_data[action]["chips"]
	for child in chips.get_children():
		child.queue_free()
	var events := _get_gamepad_events(action)
	if events.is_empty():
		var lbl := Label.new()
		lbl.text = "Unbound"
		chips.add_child(lbl)
		return
	for event in events:
		_add_chip(action, event, chips)


func _add_chip(action: String, event: InputEvent, chips: HBoxContainer) -> void:
	var chip := HBoxContainer.new()

	var lbl := Label.new()
	lbl.text = _event_name(event)

	var clear_btn := Button.new()
	clear_btn.text = "×"
	clear_btn.custom_minimum_size.x = 24
	clear_btn.pressed.connect(_on_clear_binding.bind(action, event))

	chip.add_child(lbl)
	chip.add_child(clear_btn)
	chips.add_child(chip)


func _on_add_pressed(action: String, btn: Button) -> void:
	if _listening_action == action:
		_cancel_listening()
		return
	if _listening_action != "":
		_cancel_listening()
	_listening_action = action
	_listening_button = btn
	btn.text = "..."


func _cancel_listening() -> void:
	if _listening_button:
		_listening_button.text = "+"
	_listening_action = ""
	_listening_button = null


func _input(event: InputEvent) -> void:
	if _listening_action == "":
		return
	if event is InputEventJoypadButton:
		if not event.pressed:
			return
		_apply_binding(_listening_action, event)
		_cancel_listening()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) < 0.5:
			return
		var normalized := InputEventJoypadMotion.new()
		normalized.axis       = event.axis
		normalized.axis_value = sign(event.axis_value)
		_apply_binding(_listening_action, normalized)
		_cancel_listening()
		get_viewport().set_input_as_handled()


func _apply_binding(action: String, event: InputEvent) -> void:
	for existing in InputMap.action_get_events(action):
		if _events_match(existing, event):
			return  # already bound, skip
	InputMap.action_add_event(action, event)
	_rebuild_chips(action)
	_save_all_bindings(action)


func _events_match(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventJoypadButton and b is InputEventJoypadButton:
		return a.button_index == b.button_index
	if a is InputEventJoypadMotion and b is InputEventJoypadMotion:
		return a.axis == b.axis and sign(a.axis_value) == sign(b.axis_value)
	return false


func _on_clear_binding(action: String, event: InputEvent) -> void:
	InputMap.action_erase_event(action, event)
	_rebuild_chips(action)
	_save_all_bindings(action)


func _save_all_bindings(action: String) -> void:
	var serialized: Array = []
	for event in _get_gamepad_events(action):
		if event is InputEventJoypadButton:
			serialized.append({"type": "button", "index": event.button_index})
		elif event is InputEventJoypadMotion:
			serialized.append({"type": "motion", "axis": event.axis, "value": event.axis_value})
	Data.set_config('gamepad', action, {
		"events":   serialized,
		"deadzone": InputMap.action_get_deadzone(action),
	})


func _on_deadzone_changed(value: float, action: String) -> void:
	InputMap.action_set_deadzone(action, value)
	_save_all_bindings(action)


func _on_reset_pressed() -> void:
	_cancel_listening()
	InputMap.load_from_project_settings()
	for entry in ACTIONS:
		var action: String = entry[0]
		_rebuild_chips(action)
		_rows_data[action]["dz"].value = InputMap.action_get_deadzone(action)
		Data.set_config('gamepad', action, null)


func _get_gamepad_events(action: String) -> Array:
	var result := []
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			result.append(event)
	return result


func _is_playstation() -> bool:
	for id in Input.get_connected_joypads():
		var n := Input.get_joy_name(id).to_lower()
		if "playstation" in n or "dualshock" in n or "dualsense" in n:
			return true
	return false


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if visible:
		_refresh_all_bindings()


func _event_name(event: InputEvent) -> String:
	if event is InputEventJoypadButton:
		var names := PS_BUTTON_NAMES if _is_playstation() else BUTTON_NAMES
		return names.get(event.button_index, "Btn %d" % event.button_index)
	if event is InputEventJoypadMotion:
		var names: Array = AXIS_NAMES.get(event.axis, [])
		if not names.is_empty():
			return names[0] if event.axis_value < 0.0 else names[1]
		return "Axis%d%s" % [event.axis, "+" if event.axis_value > 0.0 else "-"]
	return "?"
