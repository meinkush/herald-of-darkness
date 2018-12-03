extends "res://OIT/KOB/movement.gd"

var lifespan = 6

var caster

var damage = 1

var colliding_layer

func _ready():
	colliding_layer = PLAYER_LAYER
	collision_layer = 0
	collision_mask = WALL_LAYER

func _physics_process(delta):
	var collision = movement()
	if get_tree().is_network_server():
		lifespan -= delta
		var interactables = get_interactables(12.5,colliding_layer)
		if lifespan < 0 or !caster.get_ref() or collision:
			poof()
			set_physics_process(false)
		elif interactables:
			for body in interactables:
				if body.interaction(self, 'attack', damage) == "deflect":
					direct_to(caster.get_ref().position-position)
					lifespan = 6
					colliding_layer = ENEMY_LAYER
					break
				else:
					poof()

remote func poof():
	if get_tree().is_network_server()
		rpc("poof")
	$AnimationPlayer.play('explode')
	colliding_layer = 0

# func end():
# 	if is_network_master():
# 		rpc("_die")
#
# sync func _die():
# 	queue_free()
