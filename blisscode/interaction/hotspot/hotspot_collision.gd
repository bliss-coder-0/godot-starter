class_name HotspotCollision extends Hotspot

func _ready():
	super()
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
			
func _integrate_forces(state):
	if (state.get_contact_count() >= 1):
		local_collision_pos = state.get_contact_local_pos(0)

func _on_body_entered(body):
	var collision_position = local_collision_pos + get_position()
	_interact_handler(body, collision_position)
