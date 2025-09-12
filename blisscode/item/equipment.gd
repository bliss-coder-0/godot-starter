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

@export var head: Equipable
@export var neck: Equipable
@export var chest: Equipable
@export var waist: Equipable
@export var legs: Equipable
@export var feet: Equipable
@export var hand: Equipable
@export var left_finger: Equipable
@export var right_finger: Equipable
@export var left_hand: Equipable
@export var right_hand: Equipable

signal equipment_change
							
func equip(item: Item, equipment_slot_type: EquipmentSlotType):
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


func save():
	var data = {
		"head": head,
		"neck": neck,
		"chest": chest,
		"waist": waist,
		"legs": legs,
		"feet": feet,
		"hand": hand,
		"left_finger": left_finger,
		"right_finger": right_finger,
		"left_hand": left_hand,
		"right_hand": right_hand
	}
	return data

func restore(data):
	if data.has("head"):
		head = data["head"]
	if data.has("neck"):
		neck = data["neck"]
	if data.has("chest"):
		chest = data["chest"]
	if data.has("waist"):
		waist = data["waist"]
	if data.has("legs"):
		legs = data["legs"]
	if data.has("feet"):
		feet = data["feet"]
	if data.has("hand"):
		hand = data["hand"]
	if data.has("left_finger"):
		left_finger = data["left_finger"]
	if data.has("right_finger"):
		right_finger = data["right_finger"]
	if data.has("left_hand"):
		left_hand = data["left_hand"]
	if data.has("right_hand"):
		right_hand = data["right_hand"]
