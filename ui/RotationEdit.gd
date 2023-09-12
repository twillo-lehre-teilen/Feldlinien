extends LineEdit


func _input(event: InputEvent):
	if has_focus() && event is InputEventMouseButton && !get_global_rect().has_point(event.position):
		emit_signal("text_entered", text)


func _on_focus_entered():
	text = ""


func _on_text_entered(new_text):
	release_focus()
