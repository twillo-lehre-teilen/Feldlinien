extends MeasurementArea


func calc_area() -> float:
	return size * size


func get_area_type() -> int:
	return MeasurementAreaTypes.AreaType.SQUARE
