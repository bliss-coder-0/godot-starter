class_name Equipment extends Resource

enum EquipmentSlotType {
	None,
	Helmet,
	Neck,
	Chest,
	Waist,
	Legs,
	Boots,
	Gloves,
	LeftFinger,
	RightFinger,
	LeftHand,
	RightHand
}

var head: ItemCatalog.Item
var neck: ItemCatalog.Item
var chest: ItemCatalog.Item
var waist: ItemCatalog.Item
var legs: ItemCatalog.Item
var feet: ItemCatalog.Item
var hand: ItemCatalog.Item
var left_finger: ItemCatalog.Item
var right_finger: ItemCatalog.Item
var left_hand: ItemCatalog.Item
var right_hand: ItemCatalog.Item

signal equipment_change
							
func equip(item: ItemCatalog.Item, equipment_slot_type: EquipmentSlotType):
	match equipment_slot_type:
		EquipmentSlotType.Helmet:
			head = item
		EquipmentSlotType.Neck:
			neck = item
		EquipmentSlotType.Chest:
			chest = item
		EquipmentSlotType.Waist:
			waist = item
		EquipmentSlotType.Legs:
			legs = item
		EquipmentSlotType.Boots:
			feet = item
		EquipmentSlotType.LeftHand:
			left_hand = item
		EquipmentSlotType.RightHand:
			right_hand = item
		EquipmentSlotType.LeftFinger:
			left_finger = item
		EquipmentSlotType.RightFinger:
			right_finger = item
	equipment_change.emit()
	
func unequip(equipment_slot_type: EquipmentSlotType):
	match equipment_slot_type:
		EquipmentSlotType.Helmet:
			head = null
		EquipmentSlotType.Neck:
			neck = null
		EquipmentSlotType.Chest:
			chest = null
		EquipmentSlotType.Waist:
			waist = null
		EquipmentSlotType.Legs:
			legs = null
		EquipmentSlotType.Boots:
			feet = null
		EquipmentSlotType.LeftHand:
			left_hand = null
		EquipmentSlotType.RightHand:
			right_hand = null
		EquipmentSlotType.LeftFinger:
			left_finger = null
		EquipmentSlotType.RightFinger:
			right_finger = null
	equipment_change.emit()

func get_slot_type(slot: String):
	match slot:
		"head":
			return EquipmentSlotType.Helmet
		"neck":
			return EquipmentSlotType.Neck
		"chest":
			return EquipmentSlotType.Chest
		"waist":
			return EquipmentSlotType.Waist
		"legs":
			return EquipmentSlotType.Legs
		"feet":
			return EquipmentSlotType.Boots
		"hands":
			return EquipmentSlotType.Gloves
		"left_finger":
			return EquipmentSlotType.LeftFinger
		"right_finger":
			return EquipmentSlotType.RightFinger

func get_next_available_slot(slots: Array[String]):
	for slot in slots:
		var slot_type = get_slot_type(slot)
		if slot_type == EquipmentSlotType.Helmet and head == null:
			return slot_type
		if slot_type == EquipmentSlotType.Neck and neck == null:
			return slot_type
		if slot_type == EquipmentSlotType.Chest and chest == null:
			return slot_type
		if slot_type == EquipmentSlotType.Waist and waist == null:
			return slot_type
		if slot_type == EquipmentSlotType.Legs and legs == null:
			return slot_type
		if slot_type == EquipmentSlotType.Boots and feet == null:
			return slot_type
		if slot_type == EquipmentSlotType.Gloves and hand == null:
			return slot_type
		if slot_type == EquipmentSlotType.LeftFinger and left_finger == null:
			return slot_type
		if slot_type == EquipmentSlotType.RightFinger and right_finger == null:
			return slot_type
		if slot_type == EquipmentSlotType.LeftHand and left_hand == null:
			return slot_type
		if slot_type == EquipmentSlotType.RightHand and right_hand == null:
			return slot_type
	return EquipmentSlotType.None
