extends Control

export var simple_mode: bool = false setget set_simple_mode

onready var label_power = $CenterContainer/Panel/LabelPower
onready var needle = $CenterContainer/Panel/NeedleBase/Needle

var power: float setget set_power
var value_min: float = -0.0001
var value_max: float = 0.0001
var displayed_value: float = 0.0


func _ready() -> void:
	adjust_label_text()


func _process(delta: float) -> void:
	var value_range: float = value_max - value_min
	var display_power: float = power
	if simple_mode:
		display_power = abs(display_power) * 2.0 - value_range * 0.5
	var diff: float = display_power - displayed_value
	if abs(diff) > value_range * 0.001:
		var move: float = max((diff * sign(diff) * 5.0 + value_range * 0.1)  , value_range * 0.1) * sign(diff)
		displayed_value += move * delta
		# prevent overshooting
		var diff_after: float = display_power - displayed_value
		if (diff > 0 && diff_after < 0) || (diff < 0 && diff_after > 0):
			displayed_value = display_power
	else:
		displayed_value = display_power
	var gauge: float = (displayed_value - value_min) / (value_max - value_min)
	# max gauge is 35 degrees to the left and right
	needle.rotation_degrees = (gauge - 0.5) * 35.0 * 2.0


func set_power(value: float) -> void:
	power = value
	# power is in Vs
	if !simple_mode:
		label_power.text = "%.1f µVs" % (power * 1000000.0)
	else:
		label_power.text = "%.0f" % (abs(power * 1000000.0))
	power = clamp(power, value_min, value_max)


func adjust_label_text() -> void:
	if simple_mode:
		$LabelText.text = "MEASURED_FIELD_LINE_COUNT"
	else:
		$LabelText.text = "MEASURED_POWER"


func set_simple_mode(value: bool) -> void:
	simple_mode = value
	adjust_label_text()
