extends Panel

@export var inventory: Inventory
@export var slot: PackedScene
@export var grid: GridContainer
@export var number_slots: int

var slots: Array[ItemSlot] = []

func _ready() -> void:
	hide()
	_create_grid()
	_fill_inventory()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("inventory"):
			show()

# func _on_button_pressed() -> void:
# 	get_tree().paused = false
# 	animation_player.play("hide")

func _create_grid():
	for child in grid.get_children():
		child.queue_free()
	for i in range(number_slots):
		var s = slot.instantiate()
		slots.append(s)
		s.slot_index = i
		s.item_dropped.connect(_on_item_dropped)
		grid.add_child(s)

func _fill_inventory():
	for i in range(number_slots):
		var item = inventory.get_slot(i)
		if item:
			slots[i].set_item(item, i)

func _on_item_dropped(_item: Item, from_index: int, to_index: int):
	inventory.swap_slots(from_index, to_index)
	inventory.print_inventory()
