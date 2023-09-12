extends BaseUI


onready var knob := $PanelContainer/VBoxContainer/CenterContainer/Knob
onready var language_select_button := $LanguageSelect
onready var about_popup := $AboutPopup
onready var hints := $Hints
onready var hints_timer := $Hints/HideHintsTimer
onready var hint_rotate_area := $Hints/RotateArea
onready var hint_move_area := $Hints/MoveArea
onready var hint_change_language := $Hints/ChangeLanguage
onready var hint_rotate_magnet := $Hints/RotateMagnet
onready var rotation_edit := $PanelContainer/VBoxContainer/HBoxContainer3/Rotation
onready var rotate_speed_control := $PanelContainer/VBoxContainer/RotateSpeedControl
onready var rotate_slower_button := $PanelContainer/VBoxContainer/RotateSpeedControl/RotateSlowerButton
onready var rotate_faster_button := $PanelContainer/VBoxContainer/RotateSpeedControl/RotateFasterButton


const MIN_AUTO_ROTATE_SPEED: float = 0.2
const MAX_AUTO_ROTATE_SPEED: float = 1.8

var auto_rotate: bool = false
var auto_rotate_speed: float = 1.0


func _ready():
	rotate_speed_control.hide()


func _process(delta):
	if auto_rotate:
		# one knob value is half a rotation
		# rotate once every 5 seconds
		knob.value -= (delta * 2.0) / 5.0 * auto_rotate_speed


func set_field_strength(value: int) -> void:
	in_set_field_strength = true
	field_strength = value
	update_field_strength_text()
	var field_strength_slider := $PanelContainer/VBoxContainer/FieldStrengthSlider
	if field_strength_slider.value != value:
		field_strength_slider.value = value
	in_set_field_strength = false


func set_power(value: float) -> void:
	power = value
	$PanelContainer/VBoxContainer/PowerMeter.power = value 


func set_area_size(size: float) -> void:
	in_set_area_size = true
	area_size = size
	update_area_size_text()
	var area_size_slider := $PanelContainer/VBoxContainer/AreaSizeSlider
	if area_size_slider.value != size:
		area_size_slider.value = size
	in_set_area_size = false


func set_visible_area_type(type: int) -> void:
	var desc_label := $PanelContainer/VBoxContainer/HBoxContainer2/AreaSizeDescriptionLabel
	match type:
		MeasurementAreaTypes.AreaType.ROUND:
			desc_label.text = "AREA_DIAMETER"
		MeasurementAreaTypes.AreaType.SQUARE:
			desc_label.text = "AREA_WIDTH"
		_:
			desc_label.text = "AREA_DIAMETER"


func set_area_rotation(value: float) -> void:
	area_rotation = value
	rotation_edit.text = str(int(value))


func on_reset() -> void:
	$PanelContainer/VBoxContainer/RotateCheckbox.pressed = false
	auto_rotate = false


func update_field_strength_text() -> void:
	$PanelContainer/VBoxContainer/HBoxContainer/FieldStrengthLabel.text = "%.0f mT" % (field_strength)


func update_area_size_text() -> void:
	$PanelContainer/VBoxContainer/HBoxContainer2/AreaSizeLabel.text = "%.1f cm" % (area_size)


func show_hints() -> void:
	hint_rotate_area.set_process(true)
	hint_move_area.set_process(true)
	hint_change_language.set_process(true)
	hint_rotate_magnet.set_process(true)
	hints.show()
	showing_hints = true
	fire_hide_hints_on_touch = true
	position_hints()


func hide_hints() -> void:
	if showing_hints:
		hints_timer.stop()
		hints.hide()
		showing_hints = false
		fire_hide_hints_on_touch = false
		hint_rotate_area.set_process(false)
		hint_move_area.set_process(false)
		hint_change_language.set_process(false)
		hint_rotate_magnet.set_process(false)


func position_hints() -> void:
	hint_rotate_area.rect_global_position = knob.rect_global_position + knob.rect_size * 0.4
	hint_move_area.rect_global_position = area_pos_2d
	hint_change_language.rect_global_position = language_select_button.rect_global_position
	hint_rotate_magnet.rect_global_position = magnet_corner_pos_2d


func _on_FieldStrengthSlider_value_changed(value: float) -> void:
	if in_set_field_strength:
		return
	set_field_strength(value)
	emit_signal("change_field_strength", value)


func is_about_popup_visible() -> bool:
	return about_popup.visible


func start_hints_timer() -> void:
	hints_timer.start()


func _on_AreaSizeSlider_value_changed(value: float) -> void:
	if in_set_area_size:
		return
	set_area_size(value)
	emit_signal("change_area_size", value)


func _on_Knob_value_changed(value) -> void:
	emit_signal("rotate_area_to", value * -180.0)


func _on_HideUI_pressed() -> void:
	hide_hints()
	$PanelContainer.hide()
	$ShowUI.show()
	hint_rotate_area.hide()


func _on_ShowUI_pressed() -> void:
	$PanelContainer.show()
	$ShowUI.hide()
	hint_rotate_area.show()


func _on_LanguageSelect_pressed() -> void:
	if is_about_popup_visible():
		return
	hide_hints()
	$LanguageSelection.popup_centered()


func _on_Reset_pressed() -> void:
	knob.value = 0
	emit_signal("reset_state")


func _on_Rotation_text_entered(new_text: String) -> void:
	var value: float = float(new_text.replacen(",", "."))
	emit_signal("rotate_area_to", value)


func _on_AboutButton_pressed() -> void:
	if is_about_popup_visible():
		return
	hide_hints()
	about_popup.do_popup()


func _on_ChangeAreaType_pressed():
	emit_signal("change_area_type")


func _on_HideHintsTimer_timeout():
	hide_hints()


func _on_AboutPopup_closed():
	pass


func _on_ToggleHintsButton_pressed():
	if is_about_popup_visible():
		return
	if !showing_hints:
		show_hints()
	else:
		hide_hints()


func _on_RotateCheckbox_toggled(checked: bool):
	auto_rotate = checked
	if auto_rotate:
		auto_rotate_speed = 1.0
		update_rotate_speed_buttons_pressable()
		rotate_speed_control.show()
	else:
		rotate_speed_control.hide()


func update_rotate_speed_buttons_pressable() -> void:
	if is_equal_approx(auto_rotate_speed, MIN_AUTO_ROTATE_SPEED):
		rotate_slower_button.disabled = true
	else:
		rotate_slower_button.disabled = false
	if is_equal_approx(auto_rotate_speed, MAX_AUTO_ROTATE_SPEED):
		rotate_faster_button.disabled = true
	else:
		rotate_faster_button.disabled = false


func _on_RotateSlowerButton_pressed():
	auto_rotate_speed = clamp(auto_rotate_speed - 0.2, MIN_AUTO_ROTATE_SPEED, MAX_AUTO_ROTATE_SPEED)
	update_rotate_speed_buttons_pressable()


func _on_RotateFasterButton_pressed():
	auto_rotate_speed = clamp(auto_rotate_speed + 0.2, MIN_AUTO_ROTATE_SPEED, MAX_AUTO_ROTATE_SPEED)
	update_rotate_speed_buttons_pressable()
