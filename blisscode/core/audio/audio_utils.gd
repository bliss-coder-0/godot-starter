class_name AudioUtils extends Node
	
static func set_volume(bus_idx: int, volume: float):
	var i = bus_idx + 1
	if (volume == 0):
		AudioServer.set_bus_mute(i, true)
	else:
		if AudioServer.is_bus_mute(i):
			AudioServer.set_bus_mute(i, false)
		var db = convert_percent_to_db(volume)
		AudioServer.set_bus_volume_db(i, db)
	
static func convert_percent_to_db(percent: float) -> float:
	var scale = 20.0
	var divisor = 50.0
	return scale * log(percent / divisor) / log(10.0)
