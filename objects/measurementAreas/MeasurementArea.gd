extends KinematicBody
class_name MeasurementArea
# base class for areas that can be moved around inside the magnet


var active: bool = false setget set_active
# initially 3 centimeters
var size: float = 0.03 setget set_size
var rot: float = 0 setget set_rot
var squish_amount: float = 0.0 setget set_squish_amount


func get_collision_rid() -> int:
	return $ClickArea.get_rid()


func set_active(value: bool) -> void:
	active = value
	if active:
		show()
	else:
		hide()
	$CollisionShape.disabled = !active
	$ClickArea/CollisionShape.disabled = !active


func set_size(value: float) -> void:
	size = value
	var squish: float = 1
	if squish_amount >= 0.1:
		var rot_amount: float = abs(cos(deg2rad(rot)))
		var rot_flat: float = 0
		if rot > 90.0 && rot < 270.0:
			rot_flat = 180
		if rot >= 270.0:
			rot_flat = 360
		var rot_to_flat: float = rot_flat - rot
		squish = clamp(lerp(1, rot_amount, squish_amount), 0.01, 1)
		# where to start actually rotating when squishing in degrees
		var squish_rot_start: float = 15.0
		var squish_rot: float = max(abs(rot_to_flat) - (90.0 - squish_rot_start), 0) / squish_rot_start
		rotation_degrees.z = rot + lerp(0, rot_to_flat * (1.0 - squish_rot), squish_amount)
	else:
		rotation_degrees.z = rot
	self.scale = Vector3(size * 10.0 * squish, 0.3, size * 10.0)


func set_squish_amount(value: float) -> void:
	squish_amount = clamp(value, 0, 1)
	set_size(size)


func set_rot(value: float) -> void:
	rot = value
	set_size(size)


# this should be overridden
func calc_area() -> float:
	return 0.0


# this should be overridden
func get_area_type() -> int:
	return MeasurementAreaTypes.AreaType.ROUND
