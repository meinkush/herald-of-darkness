extends "res://mobs/mob_base.gd"

func _ready():
	actions.hit_range = ["attack"]
	actions.close     = ["dash","wait"]
	actions.far       = ["wait"]
	ring.inner        = 20
	ring.spacing      = 20
	wait_time = .5

func _physics_process(delta):
	movement(dir)
	if is_network_master():
		if target:
			if !animation.get_action() in ["attack","dash","spawn"]:
				var d = get_map_path(target.position)
				direct_to(d)
				rotate_to(target.position)
		else:
			direct_to(Vector2())

func interaction(origin, type, arg = null):
	if get_tree().is_network_server():
		if type in ["attack","shot"]:
			if animation.get_action() == "spawn":
				$status.damage(-arg)
			elif animation.get_action() != "dash":
				damage(origin, arg)
		elif type == "deflect":
			do("bash")
		elif type == "push":
			if animation.get_action() != "deflect":
				push(arg[0],arg[1])
		else:
			deferred_interaction(origin,type,arg)

func attack():
	var d = vision()
	if d:
		dash(d)
	elif target.lock(1.3) and do("attack",0,["bash"]):
		get_node("/root/Scenario").add_clue(target.position, "circle", [20])
		# direct_to(target.position-position,(position.distance_to(target.position)-$shape.shape.radius)/animation.get_length("attack")*1.7/50)
		direct_to(Vector2())

func hit():
	for object in get_interactables_in_front(35, PLAYER_LAYER):
		object.interaction(self, "attack", strenght)
