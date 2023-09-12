extends Control

signal value_changed(value)
signal rotated(amount)

onready var tex: TextureRect = $TextureRect

var dragging: bool = false
var last_drag_pos: Vector2 = Vector2.ZERO
var value: float = 0 setget set_value


func set_value(v: float) -> void:
	value = v
	var target_rotation: float = value * 360.0
	# adjust rotation to be between 0 and 360 degrees
	if target_rotation < 0:
		target_rotation += float((int(abs(target_rotation)) / 360 + 1) * 360)
	if target_rotation >= 360:
		target_rotation -= float((int(target_rotation) / 360) * 360)
	tex.rect_rotation = target_rotation
	emit_signal("value_changed", value)


func _get_minimum_size() -> Vector2:
	return Vector2(50, 50)


func _on_Knob_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed:
			var center := tex.rect_position + tex.rect_size / 2.0
			var pos: Vector2 = event.position
			# did the click happen on the round knob, or just somewhere
			# on the rectangular node?
			var circle_size := (tex.rect_size.x / 2.0)
			var to_center_dist := (pos - center).length()
			if to_center_dist <= circle_size:
				last_drag_pos = pos
				dragging = true
		else:
			last_drag_pos = Vector2.ZERO
			dragging = false
	if event is InputEventMouseMotion && dragging:
		var drag_pos: Vector2 = event.position
		var center := tex.rect_position + tex.rect_size / 2.0
		var to_last_drag := last_drag_pos - center
		var to_drag := drag_pos - center
		var angle_diff = to_last_drag.angle_to(to_drag)
		rotate_knob(rad2deg(angle_diff))
		last_drag_pos = drag_pos


func rotate_knob(var amount: float) -> void:
	var old_value := value
	value += amount / 360.0
	emit_signal("value_changed", value)
	emit_signal("rotated", value - old_value)
	var target_rotation = tex.rect_rotation + amount
	# adjust rotation to be between 0 and 360 degrees
	if target_rotation < 0:
		target_rotation += float((int(abs(target_rotation)) / 360 + 1) * 360)
	if target_rotation >= 360:
		target_rotation -= float((int(target_rotation) / 360) * 360)
	tex.rect_rotation = target_rotation
