class_name MenuStack extends Node

@export var initial_menu: String = "MainMenu"
@export var audio_transition_in: AudioStreamPlayer
@export var audio_transition_out: AudioStreamPlayer


var menus: Dictionary[String, Node] = {}
var menu_stack: Array[String] = []
var is_transitioning: bool = false
				
func _ready() -> void:
	for child in get_children():
		if child is Menu:
			menus[child.name] = child
	if initial_menu != "":
		push(initial_menu)
				
func push(menu_name: String):
	if is_transitioning:
		return
	is_transitioning = true
	if menu_stack.size() > 0:
		audio_transition_out.play()
		await transition_away_out(menu_stack.back())
	menu_stack.append(menu_name)
	audio_transition_in.play()
	await transition_in(menu_name)
	is_transitioning = false

func pop():
	if is_transitioning:
		return
	is_transitioning = true
	var prev_menu_size = menu_stack.size()
	var menu_name = menu_stack.pop_back()
	audio_transition_out.play()
	await transition_out(menu_name)
	if prev_menu_size > 1:
		audio_transition_in.play()
		await transition_away_in(menu_stack.back())
	is_transitioning = false
		
func pop_all():
	if is_transitioning:
		return
	is_transitioning = true
	var menu_name = menu_stack.pop_back()
	if menu_name:
		await transition_out(menu_name)
	menu_stack.clear()
	is_transitioning = false

func transition_in(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_in()

func transition_out(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_out()

func transition_away_in(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_away_in()

func transition_away_out(menu_name: String):
	if menus.has(menu_name):
		await menus[menu_name].transition_away_out()
