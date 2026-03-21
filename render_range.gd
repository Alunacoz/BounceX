extends ConfirmationDialog

func _on_about_to_popup():
	owner.input_disabled = true
	$HBox/Start/SpinBox.max_value = owner.path.size()
	$HBox/Start/SpinBox.value = owner.frame
	$HBox/End/SpinBox.max_value = owner.path.size()
	$HBox/End/SpinBox.value = owner.path.size()


func _on_confirmed():
	owner.input_disabled = false
	owner.render($HBox/Start/SpinBox.value, $HBox/End/SpinBox.value)


func _on_canceled():
	owner.input_disabled = false
