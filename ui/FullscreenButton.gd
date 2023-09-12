extends Control


func _ready():
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	show_state()


func _on_MaximizeButton_pressed():
	OS.window_fullscreen = true
	show_state()


func _on_MinimizeButton_pressed():
	OS.window_fullscreen = false
	show_state()


func show_state() -> void:
	var fullscreen := OS.window_fullscreen
	$MinimizeButton.visible = fullscreen
	$MaximizeButton.visible = !fullscreen


func _on_viewport_size_changed():
	show_state()
