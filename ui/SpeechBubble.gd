tool
extends Control

export(String) var text = "Hey There!" setget set_text

const ARROW_LINE_X: int = 15
const ARROW_OFFSET := Vector2(43, 8)

onready var container := $VBoxContainer
onready var arrow := $VBoxContainer/Arrow
onready var arrow_line := $VBoxContainer/Arrow/Line


func _ready():
	$VBoxContainer/PanelContainer/Label.text = text


func _process(_delta):
	if Engine.editor_hint:
		return
	container.rect_position = -(arrow.rect_position + ARROW_OFFSET)
	arrow_line.position.x = ARROW_LINE_X
	var arrow_x_offset: float = 0.0
	# adjust position if we would be outside of the visible area
	var out_of_bounds_upper: Vector2 = container.rect_global_position + container.rect_size - get_viewport_rect().size
	out_of_bounds_upper.y += 10
	if out_of_bounds_upper.x > 0:
		container.rect_position.x -= out_of_bounds_upper.x
		arrow_x_offset += out_of_bounds_upper.x
	if out_of_bounds_upper.y > 0:
		container.rect_position.y -= out_of_bounds_upper.y
	var out_of_bounds_lower: Vector2 = container.rect_global_position
	if out_of_bounds_lower.x < 0:
		container.rect_position.x -= out_of_bounds_lower.x
		arrow_x_offset += out_of_bounds_lower.x
	if out_of_bounds_lower.y < 0:
		container.rect_position.y -= out_of_bounds_lower.y
	arrow_x_offset = clamp(arrow_x_offset, -13, container.rect_size.x - ARROW_LINE_X - 28)
	arrow_line.position.x += arrow_x_offset


func set_text(value: String) -> void:
	text = value
	$VBoxContainer/PanelContainer/Label.text = text
