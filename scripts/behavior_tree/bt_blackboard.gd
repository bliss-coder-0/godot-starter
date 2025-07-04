class_name BTBlackboard extends Node

var data: Dictionary = {}

func set_var(key: String, value: Variant):
	data[key] = value

func get_var(key: String, default_value: Variant = null) -> Variant:
	return data.get(key, default_value)
	
func get_data():
	return data
