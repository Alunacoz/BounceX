extends AcceptDialog

var _wv_scroll: Node
var _wv_static: Node


func _ready() -> void:
	for n in get_tree().get_nodes_in_group("WaveformView"):
		match n.display_mode:
			1: _wv_scroll = n
			0: _wv_static = n

	var basic_theme := load("res://theme_basic.tres")
	for picker in find_children("*", "ColorPickerButton"):
		picker.get_picker().theme = basic_theme
		picker.get_child(0, true).get_child(0, true).self_modulate.a = 2

	_connect_signals()
	about_to_popup.connect(_init_state)


func _init_state() -> void:
	if _wv_scroll:
		$VBox/Scrolling/ScrollingActive.button_pressed = _wv_scroll.visible
		$VBox/Scrolling/Peak/ShowPeak.button_pressed = _wv_scroll.show_peak
		$VBox/Scrolling/Peak/PeakColorPicker.color = _wv_scroll._peak_col
		$VBox/Scrolling/RMS/ShowRMS.button_pressed = _wv_scroll.show_rms
		$VBox/Scrolling/RMS/RMSColorPicker.color = _wv_scroll._rms_col
	if _wv_static:
		$VBox/Static/StaticActive.button_pressed = _wv_static.visible
		$VBox/Static/Peak/ShowPeak.button_pressed = _wv_static.show_peak
		$VBox/Static/Peak/PeakColorPicker.color = _wv_static._peak_col
		$VBox/Static/RMS/ShowRMS.button_pressed = _wv_static.show_rms
		$VBox/Static/RMS/RMSColorPicker.color = _wv_static._rms_col


func _connect_signals() -> void:
	var d_scroll := $VBox/Scrolling
	var d_static := $VBox/Static

	if _wv_scroll:
		d_scroll.get_node("ScrollingActive").toggled.connect(func(on: bool):
			_wv_scroll.visible = on
			Data.set_config("waveform", "scroll_active", on))
		d_scroll.get_node("Peak/ShowPeak").toggled.connect(func(on: bool):
			_wv_scroll.show_peak = on
			Data.set_config("waveform", "scroll_show_peak", on))
		d_scroll.get_node("Peak/PeakColorPicker").color_changed.connect(func(c: Color):
			_wv_scroll._peak_col = c
			Data.set_config("waveform", "scroll_peak_color", c))
		d_scroll.get_node("RMS/ShowRMS").toggled.connect(func(on: bool):
			_wv_scroll.show_rms = on
			Data.set_config("waveform", "scroll_show_rms", on))
		d_scroll.get_node("RMS/RMSColorPicker").color_changed.connect(func(c: Color):
			_wv_scroll._rms_col = c
			Data.set_config("waveform", "scroll_rms_color", c))

	if _wv_static:
		d_static.get_node("StaticActive").toggled.connect(func(on: bool):
			_wv_static.visible = on and not owner.is_video_track
			%TrackSliderLarge.visible = not on or owner.is_video_track
			Data.set_config("waveform", "static_active", on))
		d_static.get_node("Peak/ShowPeak").toggled.connect(func(on: bool):
			_wv_static.show_peak = on
			Data.set_config("waveform", "static_show_peak", on))
		d_static.get_node("Peak/PeakColorPicker").color_changed.connect(func(c: Color):
			_wv_static._peak_col = c
			Data.set_config("waveform", "static_peak_color", c))
		d_static.get_node("RMS/ShowRMS").toggled.connect(func(on: bool):
			_wv_static.show_rms = on
			Data.set_config("waveform", "static_show_rms", on))
		d_static.get_node("RMS/RMSColorPicker").color_changed.connect(func(c: Color):
			_wv_static._rms_col = c
			Data.set_config("waveform", "static_rms_color", c))
