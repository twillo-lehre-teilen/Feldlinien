extends Spatial

const width: float = 3.0
const depth: float = 2.0
const MAX_FIELD_STRENGTH: int = 40
const FIELD_STRENGTH_LINE_FACTOR: float = width * 5 * depth * 5 * 0.1

onready var magnet_top := $Top
onready var magnet_bot := $Bot
onready var field_lines := $FieldLines
onready var field_lines_multimesh: MultiMesh = field_lines.multimesh
onready var top_indicators := $TopIndicators
onready var top_indicators_multimesh: MultiMesh = top_indicators.multimesh
onready var bot_indicators := $BotIndicators
onready var bot_indicators_multimesh: MultiMesh = bot_indicators.multimesh

# see_through.x is top and see_through.y is bottom
var see_through: Vector2 = Vector2.ZERO setget set_see_through
var area_pos_y: float = 0 setget set_area_pos_y


class FieldLineOptionSorter:
	extends Reference
	var line_count: int = 0
	
	func _init(line_count: int):
		self.line_count = line_count
	
	func sort(a, b) -> bool:
		var diff_a = abs(line_count - a.count)
		var diff_b = abs(line_count - b.count)
		return diff_a < diff_b


func set_field_strength(strength: int) -> void:
	if strength > MAX_FIELD_STRENGTH:
		strength = MAX_FIELD_STRENGTH
	if strength < 0:
		strength = 0
	
	# show an appropriate amount of field lines and translate them to the right position
	# to prevent stuttering when drawing a lot of field lines, this uses MultiMeshInstances
	
	var line_count: int = float(strength) * FIELD_STRENGTH_LINE_FACTOR
	var width_factor: float = width / depth
	var depth_factor: float = depth / width
	var lines_width: float = sqrt(float(line_count) * width_factor)
	var lines_depth: float = sqrt(float(line_count) * depth_factor)
	# round to values where the difference in
	# drawn line count is minimal
	var line_count_width_floor: int = floor(lines_width)
	var line_count_depth_floor: int = floor(lines_depth)
	var line_count_width_ceil: int = ceil(lines_width)
	var line_count_depth_ceil: int = ceil(lines_depth)
	var line_count_options := [
		{
			"type": "wf_df", # to see what we chose
			"width": line_count_width_floor,
			"depth": line_count_depth_floor,
			"count": line_count_width_floor * line_count_depth_floor,
		},
		{
			"type": "wf_dc",
			"width": line_count_width_floor,
			"depth": line_count_depth_ceil,
			"count": line_count_width_floor * line_count_depth_ceil,
		},
		{
			"type": "wc_df",
			"width": line_count_width_ceil,
			"depth": line_count_depth_floor,
			"count": line_count_width_ceil * line_count_depth_floor,
		},
		{
			"type": "wc_dc",
			"width": line_count_width_ceil,
			"depth": line_count_depth_ceil,
			"count": line_count_width_ceil * line_count_depth_ceil,
		},
	]
	var option_sorter := FieldLineOptionSorter.new(line_count)
	line_count_options.sort_custom(option_sorter, "sort")
	
	var line_count_width: int = line_count_options[0].width
	var line_count_depth: int = line_count_options[0].depth
	
	var line_dist_width: float = width / lines_width
	var line_diff_width: float = width / float(line_count_width) - line_dist_width
	var start_width: float = -width * 0.5 + line_dist_width * 0.5 + line_diff_width * 0.5 * line_count_width
	var line_dist_depth: float = depth / lines_depth
	var line_diff_depth: float = depth / float(line_count_depth) - line_dist_depth
	var start_depth: float = -depth * 0.5 + line_dist_depth * 0.5 + line_diff_depth * 0.5 * line_count_depth
	
	var total_line_count: int = line_count_width * line_count_depth
	field_lines_multimesh.instance_count = total_line_count
	top_indicators_multimesh.instance_count = total_line_count
	bot_indicators_multimesh.instance_count = total_line_count
	var index: int = 0
	for x in line_count_width:
		for z in line_count_depth:
			var pos := Vector3(start_width + float(x) * line_dist_width, 0, start_depth + float(z) * line_dist_depth)
			var child_transform := Transform.IDENTITY.translated(pos)
			field_lines_multimesh.set_instance_transform(index, child_transform)
			top_indicators_multimesh.set_instance_transform(index, child_transform)
			bot_indicators_multimesh.set_instance_transform(index, child_transform)
			index += 1


func set_see_through(amount: Vector2) -> void:
	# amount.x is top and amount.y is bottom
	see_through = amount
	var max_see_through: float = max(amount.x, amount.y)
	var mt: SpatialMaterial = magnet_top.get_active_material(0)
	apply_see_through_to_material(mt, max_see_through)
	var mb: SpatialMaterial = magnet_bot.get_active_material(0)
	apply_see_through_to_material(mb, max_see_through)
	# set field line visibility
	var field_line_visibility: float = max(amount.x, amount.y)
	apply_see_through_to_material(field_lines_multimesh.mesh.surface_get_material(0), field_line_visibility)
	field_lines.visible = !is_equal_approx(field_line_visibility, 1)
	# set indicator visibility
	apply_alpha_to_indicator_material(top_indicators_multimesh.mesh.surface_get_material(0), amount.x)
	top_indicators.visible = !is_equal_approx(amount.x, 0)
	apply_alpha_to_indicator_material(bot_indicators_multimesh.mesh.surface_get_material(0), amount.y)
	bot_indicators.visible = !is_equal_approx(amount.y, 0)


func apply_see_through_to_material(m: SpatialMaterial, amount: float) -> void:
	if amount <= 0:
		m.flags_transparent = false
		m.albedo_color.a = 1
	else:
		m.flags_transparent = true
		m.albedo_color.a = clamp(1.0 - amount, 0.0, 1)


func apply_alpha_to_indicator_material(m: ShaderMaterial, amount: float) -> void:
	m.set_shader_param("alpha", clamp(amount, 0, 1))


func set_area_pos_y(pos: float) -> void:
	area_pos_y = pos
	top_indicators.translation.y = pos
	bot_indicators.translation.y = pos
