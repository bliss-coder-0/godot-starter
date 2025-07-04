class_name DieState extends State

func die():
	pass
	#is_paralyzed = true
	#if garbage:
		#await get_tree().create_timer(garbage_time).timeout
		#call_deferred("queue_free")
	#else:
		#await get_tree().create_timer(garbage_time).timeout
		#hide()
	#died.emit(global_position)
