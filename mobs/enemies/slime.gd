extends "res://mobs/mob_base.gd"

func _ready():
	actions.hit_range = ["wait"]
	actions.close     = ["wait"]
	actions.far       = ["wait"]
	ring.inner        = 0
	ring.spacing      = 1

func _physics_process(delta):
	movement(Vector2())
	if get_tree().is_network_server() and target:
		if animation.get_action() == "bash":
			direct_to(Vector2())
		else:
			direct_to(target.position-position)
		#rotate_to(target.position)
	# scale = scale.linear_interpolate(Vector2(1,1)*((hp+(max_hp-float(hp))/2)/max_hp),.1)

func interaction(origin, type, arg = null):
	pass
	# if get_tree().is_network_server():
	# 	if type == "shot":
	# 		damage(origin,arg)
	# 	elif type == "attack":
	# 		if animation.get_action() == "bash" or hp <= max_hp/4:
	# 			if damage(origin,arg):
	# 				queue_free()
	# 		else:
	# 			damage(origin,hp/2)
	# 	elif type == "deflect":
	# 		do("bash")

slave func set_rot(n_rot):
	rot = n_rot
