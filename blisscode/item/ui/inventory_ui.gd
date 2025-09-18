class_name InventoryUI extends Control

@export var character: CharacterController
@export var slot: PackedScene
@export var draggable_item_scene: PackedScene
@export var container: VBoxContainer
@export var gold_label: Label
@export var grid: Vector2
@export var animation_player: AnimationPlayer

var slots: Array[Slot] = []
		
func _ready():
	character.inventory.item_added.connect(_on_item_added)
	character.inventory.item_removed.connect(_on_item_removed)
	character.inventory.gold_changed.connect(_on_gold_changed)
	character.equipment.equipment_change.connect(_on_equipment_change)
	_create_grid()
	call_deferred("_show_inventory")
	_set_gold_text(character.inventory.gold)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("inventory"):
			get_tree().paused = true
			animation_player.play("show")
			_show_inventory()

func _create_grid():
	if not container:
		return
	for child in container.get_children():
		child.queue_free()
	var slot_index = 0
	for i in range(grid.y):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 24)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.name = "Row" + str(i)
		for j in range(grid.x):
			var col = slot.instantiate()
			col.name = "Row" + str(i) + "Col" + str(j)
			col.slot_index = slot_index
			slot_index += 1
			slots.append(col)
			row.add_child(col)
		container.add_child(row)

func _on_item_added(_item: Item, _pos: Vector2):
	call_deferred("_free_inventory")

func _on_item_removed(_item: Item, _pos: Vector2):
	call_deferred("_free_inventory")

func _free_inventory():
	for item in get_tree().get_nodes_in_group("draggable_item"):
		item.queue_free()
	call_deferred("_show_inventory")
	
func _show_inventory():
	if not character:
		return
	for s in slots:
		var item = character.inventory.get_slot(s.slot_index)
		if item:
			var draggable_item = draggable_item_scene.instantiate()
			draggable_item.inventory = character.inventory
			draggable_item.call_deferred("set_item", item)
			s.add_child(draggable_item)
			draggable_item.show()
			
func _on_equipment_change():
	print("_on_equipment_change")
	
func _on_gold_changed(gold):
	_set_gold_text(gold)
	
func _set_gold_text(gold):
	gold_label.text = "Gold: " + str(gold)

func _on_button_pressed() -> void:
	get_tree().paused = false
	animation_player.play("hide")
