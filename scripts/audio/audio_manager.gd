extends Node

var save_file_path = "user://save"
var save_file_name = "audio_data.json"
var bus_idx_volume = [50, 50, 50]

signal loaded

func _ready():
	call_deferred("_load")
	
func _load():
	restore()
	AudioServer.set_bus_volume_db(0, convert_percent_to_db(50))
	for i in range(3):
		AudioServer.set_bus_volume_db(i + 1, convert_percent_to_db(bus_idx_volume[i]))
	loaded.emit()
	
func set_volume(bus_idx, volume):
	bus_idx_volume[bus_idx] = volume
	var i = bus_idx + 1
	if (volume == 0):
		AudioServer.set_bus_mute(i, true)
	else:
		if AudioServer.is_bus_mute(i):
			AudioServer.set_bus_mute(i, false)
		var db = convert_percent_to_db(volume)
		AudioServer.set_bus_volume_db(i, db)
		
func convert_percent_to_db(percent):
	var scale = 20
	var divisor = 50
	return scale * log(percent / divisor) / log(10)

func save():
	var data = {
		"bus_idx_volume": bus_idx_volume
	}
	GameUtils.save(save_file_path.path_join(save_file_name), data)
	return data

func restore():
	GameUtils.verify_save_dir(save_file_path)
	var data = GameUtils.restore(save_file_path.path_join(save_file_name))
	if data == null:
		data = save()
	elif data["bus_idx_volume"]:
		bus_idx_volume = data["bus_idx_volume"]
	
