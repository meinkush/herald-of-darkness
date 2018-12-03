extends "res://OIT/KOB/interact.gd"

var damage = 1

var caster

func _ready():
	collision_layer = 0
	collision_mask = 0

func poof():
	if get_tree().is_network_server():
		for object in get_interactables(66,PLAYER_LAYER):
			object.interaction(self, 'attack',damage)
		finish()

remote func finish():
	if get_tree().is_network_server():
		rpc("finish")
	queue_free()
