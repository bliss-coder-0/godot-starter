@tool
extends Node

var data_store = {}
var data_store_dir = "res://data/"

func _ready() -> void:
	_create_data_store()

func _create_data_store():
	var files = FilesUtil.find_files(data_store_dir, "json")
	# Create nested structure based on directory paths
	for file_info in files:
		var file_data = FilesUtil.restore(file_info.full_path)
		if file_data != null:
			var current_dict = data_store
			# Navigate through directory structure
			for dir_name in file_info.path:
				if not current_dict.has(dir_name):
					current_dict[dir_name] = {}
				current_dict = current_dict[dir_name]
			
			# Store file data using filename without extension as key
			var file_key = file_info.filename.get_basename()
			current_dict[file_key] = file_data
		else:
			print("Failed to load: ", file_info.full_path)

# Get data from nested path (e.g., "items/currency" or "soundtracks/chiptune_1")
func get_store_by_path(path: String) -> Dictionary:
	var path_parts = path.split("/")
	var current_dict = data_store
	
	for part in path_parts:
		if current_dict.has(part):
			current_dict = current_dict[part]
		else:
			print("Path not found: ", path, " at part: ", part)
			return {}
	
	return current_dict

# Get all data under a specific directory (e.g., all items)
func get_store_directory(directory: String) -> Dictionary:
	if data_store.has(directory):
		return data_store[directory]
	else:
		print("Directory not found: ", directory)
		return {}

func create_item(key: StringName, item_name: String) -> Item:
	if Engine.is_editor_hint():
		_create_data_store()
		
	var store = get_store_by_path(key)

	if store == null:
		print("Store not found: ", key)
		return null

	if not store.has("items"):
		print("Store has no items: ", key)
		return null
	
	var item_index = store.items.find_custom(func(item): return item.name == item_name)

	if item_index == -1:
		print("Item not found: ", item_name)
		return null
	
	var item_data = store.items[item_index]

	if not store.has("spriteSheet"):
		print("Store has no spriteSheet: ", key)
		return null

	if not store.spriteSheet.has("atlas"):
		print("SpriteSheet has no atlas: ", key)
		return null

	var sprite_sheet = store.spriteSheet
	var atlas = sprite_sheet.atlas

	if not item_data.has("type"):
		print("Item has no type: ", item_name)
		return null

	if item_data.type == "currency":
		return create_currency(item_data, atlas)
	elif item_data.type == "melee_weapon":
		return create_melee_weapon(item_data, atlas)
	elif item_data.type == "ranged_weapon":
		return create_ranged_weapon(item_data, atlas)
	elif item_data.type == "armor":
		return create_armor(item_data, atlas)
	elif item_data.type == "consumable":
		return create_consumable(item_data, atlas)

	return null

func fill_texture(item: Item, item_data, atlas):
	if atlas != null:
		if atlas.has("path"):
			item.texture = load(atlas.path)
		if atlas.has("hframes"):
			item.hframes = atlas.hframes
		if atlas.has("vframes"):
			item.vframes = atlas.vframes
		if item_data.has("frame"):
			item.frame = item_data.frame

func create_currency(item_data, atlas):
	var currency = Currency.new()
	currency.restore(item_data)
	fill_texture(currency, item_data, atlas)
	return currency

func create_melee_weapon(item_data, atlas):
	var melee_weapon = MeleeWeapon.new()
	melee_weapon.restore(item_data)
	fill_texture(melee_weapon, item_data, atlas)
	return melee_weapon

func create_ranged_weapon(item_data, atlas):
	var ranged_weapon = RangedWeapon.new()
	ranged_weapon.restore(item_data)
	fill_texture(ranged_weapon, item_data, atlas)
	return ranged_weapon

func create_armor(item_data, atlas):
	var armor = Armor.new()
	armor.restore(item_data)
	fill_texture(armor, item_data, atlas)
	return armor

func create_consumable(item_data, atlas):
	var consumable = Consumable.new()
	consumable.restore(item_data)
	fill_texture(consumable, item_data, atlas)
	return consumable
