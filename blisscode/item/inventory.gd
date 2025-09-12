class_name Inventory extends Resource

@export var gold: int = 0
@export var max_gold: int = 10000
@export var max_slots: int = 50
@export var items: Array[Item] = []

signal item_added(item: Item, pos: Vector2)
signal item_removed(item: Item, pos: Vector2)
signal gold_changed(gold: int, pos: Vector2)
	
func add(item: Item, pos: Vector2):
	print(item)
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
	item_added.emit(item, pos)
	
func remove(item: Item, pos: Vector2):
	items.erase(item)
	item_removed.emit(item, pos)

# func add_quantity(item_id: String, amount: int):
# 	#item.quantity += amount
# 	#if item.quantity <= 0:
# 		#remove(item)
# 	#item_removed.emit(item, Vector2.ZERO)
# 	pass
	
func add_gold(amount: int, pos: Vector2):
	gold += amount
	if gold > max_gold:
		gold = max_gold
	gold_changed.emit(gold, pos)
	
func in_inventory(item: Item):
	var index = items.find(item)
	return index != -1
	
func get_slot(slot_index) -> Item:
	return items[slot_index]
			
func get_next_available_slot():
	for i in items.size():
		if items[i] == null:
			return i
	return -1

func save():
	var data = {
		"gold": gold,
		"items": items.map(func(item: Item): return item.save())
	}
	return data
	
func restore(data):
	if data.has("gold"):
		gold = data["gold"]
	if data.has("items"):
		items = data["items"].map(func(item: Item): return item.restore(item))
