class_name Inventory extends Resource

@export var gold: int = 0
@export var max_gold: int = 10000
@export var max_slots = 50

var items = []

signal item_added(item_id: String, pos: Vector2)
signal item_removed(item_id: String, pos: Vector2)
signal gold_changed(gold: int, position: Vector2)
	
func add(item_id: String, pos: Vector2):
	var item = ItemCatalog.get_item(item_id)
	# print(item)
	# Duplicate the resource to make a brand new instance to put into inventory
	# The bad side of this will make the in_inventory function not work
	# since its checking the actual object and not some id
	
	# if in_inventory(item_id) and item.has("is_unique") and item.is_unique:
	# 	print("Item is unique")
	# 	return
		
	# if in_inventory(item_id) and item.has("is_stackable") and item.has("max_stackable_count") and item.is_stackable and item.quantity < item.max_stackable_count:
	# 	print("Add quantity")
	# 	add_quantity(item_id, item.quantity)
	# 	return

	# var slot_index = get_next_available_slot()
	# if slot_index >= 0:
	# 	if items[slot_index] == null:
	# 		var prev_index = get_slot_index(item)
	# 		items[slot_index] = item
	# 		items[prev_index] = null
	# 		item_added.emit(item_id, pos)
	
func remove(item_id: String):
	items.erase(item_id)
	item_removed.emit(item_id, Vector2.ZERO)

func add_quantity(item_id: String, amount: int):
	#item.quantity += amount
	#if item.quantity <= 0:
		#remove(item)
	#item_removed.emit(item, Vector2.ZERO)
	pass
	
func add_gold(amount: int):
	gold += amount
	if gold > max_gold:
		gold = max_gold
	gold_changed.emit(gold, Vector2.ZERO)
	
func in_inventory(item_id: String):
	var index = items.find(func(i): return i.id == item_id)
	return index != -1
	
func get_slot(slot_index) -> String:
	return items[slot_index]
	
func get_slot_index(item_id: String):
	return items.find(item_id)
		
func get_next_available_slot():
	for i in items.size():
		if items[i] == null:
			return i
	return -1

func save():
	var data = {
		"gold": gold,
		"items": items
	}
	return data
	
func restore(data):
	if data.has("gold"):
		gold = data["gold"]
	if data.has("items"):
		items = data["items"]
