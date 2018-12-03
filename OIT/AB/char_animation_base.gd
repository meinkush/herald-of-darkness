extends "res://OIT/AB/animation_base.gd"

onready var character = get_node("../")

func _process(delta):
	if character.f_dir:
		set_movement("run")
	else:
		set_movement("idle")

func set_movement(movement):
	if !get_action() and current_animation != movement:
		play(movement)
