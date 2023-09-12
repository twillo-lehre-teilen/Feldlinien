extends MeasurementArea


func calc_area() -> float:
	var radius: float = size * 0.5
	var area: float = PI * radius * radius
	return area


func get_area_type() -> int:
	return MeasurementAreaTypes.AreaType.ROUND
