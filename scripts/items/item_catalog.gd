extends Node

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

enum Effect {
	FIRE_DAMAGE,
	FROST_DAMAGE,
	HEALTH_REGEN,
	MANA_BOOST,
	CRITICAL_STRIKE,
	SPEED_INCREASE,
	POISON,
	DEFENSE_BOOST,
	ATTACK_BOOST,
	XP_GAIN
}

class Item:
	var id: String
	var frame: int
	var category: Array[String]
	var itemType: String
	var variant: String
	var is_level_unique: bool = false
	var is_game_unique: bool = false
	var is_stackable: bool = false
	var max_stackable_count: int = 1
	var sprite: Sprite2D
	var name: String = ""
	var description: String = ""
	var weight: int = 0
	var sell_price: int = 0
	var buy_price: int = 0
	var rarity: Rarity = Rarity.COMMON
	var level_requirement: int = 0
	var effect: String = ""

class Currency extends Item:
	var amount: int = 0

class Equipable extends Item:
	var slot: Array[String]
	var equip_on_pickup: bool = false

class Weapon extends Equipable:
	var damage: int = 0
	
class MeleeWeapon extends Weapon:
	var swing_rate: float = 0.0

class RangedWeapon extends Weapon:
	var fire_rate: float = 0.0
	var projectile: String = ""
	var max_ammo: int = 0
	var unlimited_ammo: bool = false
	var ammo: int = 0

class Armor extends Equipable:
	var defense: int = 0

class Consumable extends Item:
	var health: int = 0
	var mana: int = 0
	var stamina: int = 0
	var consume_on_pickup: bool = false

var item_catalog = {}
var items_by_id: Dictionary[String, Item] = {}

func _ready() -> void:
	_create_item_catalog()

func _create_item_catalog():
	item_catalog['currency'] = GameUtils.restore("res://data/items/currency.json")
	#item_catalog['food'] = GameUtils.restore("res://data/items/food.json")
	#item_catalog['weapons_and_armor'] = GameUtils.restore("res://data/items/weapons_and_armor.json")
	item_catalog['potions'] = GameUtils.restore("res://data/items/potions.json")
	item_catalog['guns'] = GameUtils.restore("res://data/items/guns.json")

	for map_name in item_catalog:
		var map_data = item_catalog[map_name]
		var sprite_sheet = map_data.spriteSheet
		var atlas = sprite_sheet.atlas
		
		for item_data in map_data.items:
			var item = _create_item_from_category(map_name, item_data, atlas)
			if item != null:
				items_by_id[item.id] = item

func _create_item_from_category(map_name: String, item_data, atlas):
	if not item_data.has("category"):
		return null
	var category = item_data.category
	var first_category = category[0] if category.size() > 0 else ""
	var second_category = category[1] if category.size() > 1 else ""
	var third_category = category[2] if category.size() > 2 else ""
	
	if first_category == "currency":
		return _create_currency(map_name, item_data, atlas)
	elif first_category == "equipable":
		if second_category == "weapon":
			if third_category == "melee":
				return _create_melee_weapon(map_name, item_data, atlas)
			elif third_category == "ranged":
				return _create_ranged_weapon(map_name, item_data, atlas)
		elif second_category == "armor":
			return _create_armor(map_name, item_data, atlas)
	elif first_category == "consumable":
		return _create_consumable(map_name, item_data, atlas)
	return null

func _create_item(map_name: String, item_data, atlas):
	if not item_data.has("id"):
		print("Item data has no id")
		return null
	var item = Item.new()
	_fill_item_data(map_name, item, item_data)
	_fill_sprite(item, item_data, atlas)
	return item

func _fill_item_data(map_name: String, item: Item, item_data):
	var item_id = map_name + "_" + item_data.id
	item.id = item_id
	if item_data.has("frame"):
		item.frame = item_data.frame
	if item_data.has("category"):
		for category in item_data.category:
			item.category.append(category)
	if item_data.has("itemType"):
		item.itemType = item_data.itemType
	if item_data.has("variant"):
		item.variant = item_data.variant
	if item_data.has("is_level_unique"):
		item.is_level_unique = item_data.is_level_unique
	if item_data.has("is_game_unique"):
		item.is_game_unique = item_data.is_game_unique
	if item_data.has("is_stackable"):
		item.is_stackable = item_data.is_stackable
	if item_data.has("max_stackable_count"):
		item.max_stackable_count = item_data.max_stackable_count
	if item_data.has("name"):
		item.name = item_data.name
	if item_data.has("description"):
		item.description = item_data.description
	if item_data.has("weight"):
		item.weight = item_data.weight
	if item_data.has("sell_price"):
		item.sell_price = item_data.sell_price
	if item_data.has("buy_price"):
		item.buy_price = item_data.buy_price

func _fill_sprite(item: Item, item_data, atlas):
	if atlas != null:
		var sprite = Sprite2D.new()
		if atlas.has("path"):
			sprite.texture = load(atlas.path)
		if atlas.has("hframes"):
			sprite.hframes = atlas.hframes
		if atlas.has("vframes"):
			sprite.vframes = atlas.vframes
		if item_data.has("frame"):
			sprite.frame = item_data.frame
		item.sprite = sprite

func _create_currency(map_name: String, item_data, atlas):
	var currency = Currency.new()
	_fill_item_data(map_name, currency, item_data)
	_fill_sprite(currency, item_data, atlas)
	if item_data.has("amount"):
		currency.amount = item_data.amount
	return currency

func _fill_equipable_data(map_name: String, equipable: Equipable, item_data, atlas):
	_fill_item_data(map_name, equipable, item_data)
	_fill_sprite(equipable, item_data, atlas)
	if item_data.has("slot"):
		for slot in item_data.slot:
			equipable.slot.append(slot)
	return equipable

func _fill_weapon_data(map_name: String, weapon: Weapon, item_data, atlas):
	_fill_item_data(map_name, weapon, item_data)
	_fill_sprite(weapon, item_data, atlas)
	if item_data.has("damage"):
		weapon.damage = item_data.damage
	if item_data.has("equip_on_pickup"):
		weapon.equip_on_pickup = item_data.equip_on_pickup
	return weapon

func _create_melee_weapon(map_name: String, item_data, atlas):
	var melee_weapon = MeleeWeapon.new()
	_fill_weapon_data(map_name, melee_weapon, item_data, atlas)
	if item_data.has("swing_rate"):
		melee_weapon.swing_rate = item_data.swing_rate
	return melee_weapon

func _create_ranged_weapon(map_name: String, item_data, atlas):
	var ranged_weapon = RangedWeapon.new()
	_fill_weapon_data(map_name, ranged_weapon, item_data, atlas)
	if item_data.has("fire_rate"):
		ranged_weapon.fire_rate = item_data.fire_rate
	if item_data.has("projectile"):
		ranged_weapon.projectile = item_data.projectile
	if item_data.has("max_ammo"):
		ranged_weapon.max_ammo = item_data.max_ammo
	if item_data.has("unlimited_ammo"):
		ranged_weapon.unlimited_ammo = item_data.unlimited_ammo
	if item_data.has("ammo"):
		ranged_weapon.ammo = item_data.ammo
	return ranged_weapon

func _create_armor(map_name: String, item_data, atlas):
	var armor = Armor.new()
	_fill_equipable_data(map_name, armor, item_data, atlas)
	if item_data.has("defense"):
		armor.defense = item_data.defense
	return armor

func _create_consumable(map_name: String, item_data, atlas):
	var consumable = Consumable.new()
	_fill_item_data(map_name, consumable, item_data)
	_fill_sprite(consumable, item_data, atlas)
	if item_data.has("health"):
		consumable.health = item_data.health
	if item_data.has("mana"):
		consumable.mana = item_data.mana
	if item_data.has("stamina"):
		consumable.stamina = item_data.stamina
	if item_data.has("consume_on_pickup"):
		consumable.consume_on_pickup = item_data.consume_on_pickup
	return consumable

func get_item(id: String):
	if items_by_id.has(id):
		return items_by_id[id]
	return null

func get_random_item():
	return items_by_id[items_by_id.keys()[randi() % items_by_id.size()]]

func get_random_item_id():
	return get_random_item().id

func weighted_random(choices: Array[Rarity], weights: Array[float]):
	var totalWeight = weights.reduce(func(acc, w): return acc + w, 0)
	var random = randf() * totalWeight

	var cumulative = 0
	for i in range(choices.size()):
		cumulative += weights[i]
		if random < cumulative:
			return choices[i]

func generate_random_item(playerLevel: int):
	var rarities: Array[Rarity] = [Rarity.COMMON, Rarity.UNCOMMON, Rarity.RARE, Rarity.EPIC, Rarity.LEGENDARY]
	var rarityWeightDefaults = [50, 30, 16, 4, 0]
	var rarityWeights: Array[float] = [
		(rarityWeightDefaults[0] - (playerLevel - 1)),
		(rarityWeightDefaults[1] + (playerLevel - 1) * 0.25),
		(rarityWeightDefaults[2] + (playerLevel - 1) * 0.25),
		(rarityWeightDefaults[3] + (playerLevel - 1) * 0.25),
		(rarityWeightDefaults[4] + (playerLevel - 1) * 0.25)
	]

	var random_item = get_random_item()
	random_item.id = str(randi())
	random_item.name = ""
	random_item.rarity = weighted_random(rarities, rarityWeights)
	random_item.effect = Effect.keys()[randi() % Effect.size()]
	random_item.level_requirement = randi() % 50 + 1
	random_item.buy_price = randi() % 1000 + 100
	random_item.sell_price = random_item.buy_price * 0.5

	items_by_id[random_item.id] = random_item

	return random_item

func generate_random_item_id(playerLevel: int):
	return generate_random_item(playerLevel).id
