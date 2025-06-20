class_name FollowPathState extends State

@export var path: Path2D
@export var paths: Array[Path2D]
@export var speed: float = 1

var path_follow: PathFollow2D
var follow_path_velocity
var previous_global_position: Vector2 = Vector2.ZERO
	
func _ready() -> void:
	if path == null:
		if paths.size() > 0:
			# Select a random path from the available paths
			var random_index = randi() % paths.size()
			path = paths[random_index]
		else:
			push_error("No paths available for FollowPathState")

	path_follow = path.get_child(0)
	
func process_physics(delta: float) -> void:
	_follow_path(delta)

func _follow_path(delta: float) -> void:
	if path_follow == null:
		return
	handle_path_progress(delta)
	calculate_velocity_from_path(delta)
	handle_flip()
	
func handle_path_progress(delta: float):
	path_follow.progress_ratio += speed * delta
	parent.global_position = path_follow.global_position

func handle_flip():
	var direction = follow_path_velocity.x
	if direction > 0:
		parent.scale.x = parent.scale.y * 1
	else:
		parent.scale.x = parent.scale.y * -1

func calculate_velocity_from_path(delta):
	follow_path_velocity = (path_follow.global_position - previous_global_position) / delta
	previous_global_position = path_follow.global_position
