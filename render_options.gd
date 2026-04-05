extends ConfirmationDialog

func _on_about_to_popup():
	owner.input_disabled = true
	$VBox/Range/Start/SpinBox.max_value = owner.path.size()
	$VBox/Range/End/SpinBox.max_value = owner.path.size()
	$VBox/Range/End/SpinBox.value = owner.path.size()


func _on_from_current_pos_toggled(toggled_on: bool) -> void:
	$VBox/Range/Start/SpinBox.value_changed.disconnect(_on_start_value_changed)
	$VBox/Range/Start/SpinBox.set_value(owner.frame if toggled_on else 0)
	$VBox/Range/Start/SpinBox.value_changed.connect(_on_start_value_changed)


func _on_start_value_changed(value: float) -> void:
	if $VBox/FromCurrentPos.button_down:
		$VBox/FromCurrentPos.set_pressed_no_signal(false)


func _on_lead_in_toggled(toggled_on: bool) -> void:
	owner.apply_lead_in = toggled_on


func _on_lead_out_toggled(toggled_on: bool) -> void:
	owner.apply_lead_out = toggled_on


func _on_confirmed():
	owner.input_disabled = false
	owner.render($VBox/Range/Start/SpinBox.value, $VBox/Range/End/SpinBox.value)


func _on_canceled():
	owner.input_disabled = false
