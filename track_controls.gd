extends HBoxContainer

const size_small := Vector2(0.9, 0.9)
const size_normal := Vector2(1, 1)

func _ready():
	$Play.self_modulate.a = 0
	$Pause.self_modulate.a = 0


func _on_play_toggled(button_pressed):
	if button_pressed:
		$Play.disabled = true
		$Play.self_modulate.a = 1
		$Pause.disabled = false
		$Pause.button_pressed = false
		$Pause/Icon.self_modulate.a = 1
		$Pause/Icon.scale = size_normal
		$Play.button_pressed = true
	else:
		$Play.disabled = false
		$Play.self_modulate.a = 0


func _on_pause_toggled(button_pressed):
	if button_pressed:
		$Pause.disabled = true
		$Pause.self_modulate.a = 1
		$Play.button_pressed = false
		owner._set_track_paused(true)
		$Play/Icon.scale = size_normal
		$Play.button_pressed = false
	else:
		$Pause.disabled = false
		$Pause.self_modulate.a = 0


func _on_play_mouse_entered():
	if not $Play.disabled and not $Play.button_pressed:
		$Play/Icon.scale = size_small


func _on_play_mouse_exited():
	if not $Play.disabled:
		$Play/Icon.scale = size_normal


func _on_pause_mouse_entered():
	if not $Pause.disabled and not $Pause.button_pressed:
		$Pause/Icon.scale = size_small


func _on_pause_mouse_exited():
	if not $Pause.disabled:
		$Pause/Icon.scale = size_normal
