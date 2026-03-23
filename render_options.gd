extends ConfirmationDialog

func _on_about_to_popup():
	owner.input_disabled = true
	$VBox/Range/Start/SpinBox.max_value = owner.path.size()
	$VBox/Range/End/SpinBox.max_value = owner.path.size()
	$VBox/Range/End/SpinBox.value = owner.path.size()


func _on_from_current_pos_toggled(toggled_on: bool) -> void:
	$VBox/Range/Start/SpinBox.value = owner.frame if toggled_on else 0


func _on_lead_in_toggled(toggled_on: bool) -> void:
	owner.apply_lead_in = toggled_on


func _on_lead_out_toggled(toggled_on: bool) -> void:
	owner.apply_lead_out = toggled_on


func _on_confirmed():
	owner.input_disabled = false
	owner.render($VBox/Range/Start/SpinBox.value, $VBox/Range/End/SpinBox.value)


func _on_canceled():
	owner.input_disabled = false
