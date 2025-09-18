class_name ItemSlot extends Panel

@onready var icon: TextureRect = $Icon
@export var item: Item

var slot_index: int

signal item_dropped(i: Item, from_index: int, to_index: int)

func _ready() -> void:
	update_ui()

func _process(_delta: float) -> void:
	if Input.get_current_cursor_shape() == CURSOR_FORBIDDEN:
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)

func set_item(i: Item, index: int):
	item = i
	slot_index = index
	update_ui()

func get_item():
	return item

func update_ui() -> void:
	if not item:
		icon.texture = null
		return
	
	if item.texture and (item.hframes > 1 or item.vframes > 1):
		icon.texture = create_atlas_texture(item)
	else:
		icon.texture = item.texture
	
	tooltip_text = item.name

func create_atlas_texture(item_data: Item) -> AtlasTexture:
	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = item_data.texture
	
	# Calculate frame dimensions
	var frame_width = float(item_data.texture.get_width()) / float(item_data.hframes)
	var frame_height = float(item_data.texture.get_height()) / float(item_data.vframes)
	
	# Calculate frame position
	var frame_x = (item_data.frame % item_data.hframes) * frame_width
	@warning_ignore("integer_division")
	var frame_y = (item_data.frame / item_data.hframes) * frame_height # Intentional integer division for row calculation
	
	# Set the region for this specific frame
	atlas_texture.region = Rect2(frame_x, frame_y, frame_width, frame_height)
	
	return atlas_texture

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not item:
		return
	
	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(size.x / 2, size.y / 2)
	preview.self_modulate = Color.TRANSPARENT
	c.modulate = Color(c.modulate, 0.5)
	c.scale = Vector2(2.0, 2.0)
	
	set_drag_preview(c)
	icon.hide()
	return self

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tmp = item
	item = data.item
	data.item = tmp
	icon.show()
	data.show()
	update_ui()
	data.update_ui()
	item_dropped.emit(item, data.slot_index, slot_index)

var data_bk
func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data_bk:
				data_bk.icon.show()
				data_bk = null
