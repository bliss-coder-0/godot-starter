class_name GameData extends Resource

var first_time_loaded = false
var current_scene_path = ""
var from_scene_path = ""
var prev_door_id = ""
var current_door_id = ""
var restoring_scene = false

func set_default():
	first_time_loaded = true
	return save()

func save():
	var data = {
		"first_time_loaded": false,
		"prev_door_id": prev_door_id,
		"current_door_id": current_door_id,
		"current_scene_path": current_scene_path,
		"from_scene_path": from_scene_path,
		"restoring_scene": restoring_scene
	}
	return data

func restore(data):
	if data.has("first_time_loaded"):
		first_time_loaded = data["first_time_loaded"]
	if data.has("prev_door_id"):
		prev_door_id = data["prev_door_id"]
	if data.has("current_door_id"):
		current_door_id = data["current_door_id"]
	if data.has("current_scene_path"):
		current_scene_path = data["current_scene_path"]
	if data.has("from_scene_path"):
		from_scene_path = data["from_scene_path"]
	if data.has("restoring_scene"):
		restoring_scene = data["restoring_scene"]

func reset():
	first_time_loaded = false
	prev_door_id = ""
	current_door_id = ""
	current_scene_path = ""
	from_scene_path = ""
	restoring_scene = false
