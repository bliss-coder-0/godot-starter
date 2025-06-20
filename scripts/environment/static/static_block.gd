class_name StaticBlock extends StaticBody2D

@export var hp: int = 100
@export var max_hp: int = 100

@export var ap: int = 100
@export var max_ap: int = 100

signal spawned(pos: Vector2)
signal died(pos: Vector2)
signal hp_changed(hp_change: int, max_hp: int)
signal ap_changed(ap_change: int, max_ap: int)

func spawn(spawn_position: Vector2 = Vector2.ZERO):
	position = spawn_position
	hp = max_hp
	ap = max_ap
	show()
	spawned.emit(global_position)
	hp_changed.emit(hp, max_hp)
	ap_changed.emit(ap, max_ap)

func die():
	died.emit(global_position)
	call_deferred("queue_free")

func take_damage(amount: int):
	if ap > 0:
		ap -= amount
		ap_changed.emit(ap, max_ap)
		return
	
	hp -= amount

	# Check for death
	if hp <= 0:
		hp_changed.emit(hp, max_hp)
		die()
		return
	
	# Emit current health
	hp_changed.emit(hp, max_hp)
