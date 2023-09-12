extends Control
class_name BaseUI

signal change_field_strength(strength)
signal rotate_area_to(value)
signal change_area_size(size)
signal update_mouse_target
signal reset_mouse_target
signal mouse_moved(diff, pos)
signal reset_state
signal zoom(amount)
signal change_area_type


var field_strength: int setget set_field_strength
var power: float setget set_power
var area_size: float setget set_area_size
var area_rotation: float setget set_area_rotation
var area_pos_2d := Vector2.ZERO
var magnet_corner_pos_2d := Vector2.ZERO

var touch_points = {}
var ignore_next_mouse_move: bool = false
var showing_hints: bool = true
var fire_hide_hints_on_touch: bool = true
# needed to ignore manually setting the slider value
# which fires a signal, which would then lead to calling set_area_size()
var in_set_area_size: bool = false
# same as above
var in_set_field_strength: bool = false


func _process(_delta):
	if showing_hints:
		position_hints()


func _input(event: InputEvent) -> void:
	if fire_hide_hints_on_touch && event is InputEventScreenTouch && event.pressed:
		fire_hide_hints_on_touch = false
		start_hints_timer()
	if event is InputEventScreenTouch && !event.pressed:
		touch_points.erase(event.index)
		ignore_next_mouse_move = true
		if touch_points.empty():
			emit_signal("reset_mouse_target")
	elif !is_about_popup_visible():
		if event.is_action_pressed("zoom_in"):
			emit_signal("zoom", -0.1)
		elif event.is_action_pressed("zoom_out"):
			emit_signal("zoom", 0.1)


func _on_UI_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch && event.pressed:
		if touch_points.size() == 0:
			emit_signal("update_mouse_target")
		touch_points[event.index] = event.position
	if event is InputEventScreenDrag && touch_points.has(event.index):
		if touch_points.size() >= 2:
			var center := Vector2.ZERO
			for p in touch_points.values():
				center += p
			center /= float(touch_points.size())
			var point = touch_points[event.index]
			var to_center_before: Vector2 = center - point
			var to_center_now: Vector2 = center - event.position
			var diff: float = to_center_before.length() - to_center_now.length()
			emit_signal("zoom", diff * 0.005)
			emit_signal("mouse_moved", to_center_before - to_center_now, center)
		else:
			if ignore_next_mouse_move:
				ignore_next_mouse_move = false
			else:
				var mouse_diff: Vector2 = event.relative
				var mouse_pos: Vector2 = event.position
				emit_signal("mouse_moved", mouse_diff, mouse_pos)
		touch_points[event.index] = event.position


func set_field_strength(_value: int) -> void:
	pass


func set_power(_value: float) -> void:
	pass


func set_area_size(_size: float) -> void:
	pass


func set_area_rotation(_value: float) -> void:
	pass


func set_visible_area_type(_type: int) -> void:
	pass


func on_reset() -> void:
	pass


func position_hints() -> void:
	pass


func start_hints_timer() -> void:
	pass


func is_about_popup_visible() -> bool:
	return false
