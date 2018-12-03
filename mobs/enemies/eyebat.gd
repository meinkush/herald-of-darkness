extends "res://mobs/mob_base.gd"

var charged = []

var objective = Vector2()

func _ready():
	actions.hit_range = ["dash"]
	actions.close     = ["dash","coil"]
	actions.far       = ["wait"]
	ring.inner        = 300
	ring.spacing      = 50

func _physics_process(delta):
	movement(dir)
	if is_network_master():
		if target:
			var action = animation.get_action()
			if action == "attack":
				direct_to(objective,speed*3)
				for object in get_interactables_in_front(50, PLAYER_LAYER):
					if !object in charged:
						object.interaction(self, "attack",1)
						object.interaction(self, "push", [position, 7])
						charged.append(object)
			elif action == "attack_r":
				direct_to(get_map_path(target.position), speed*2)
			elif action in ["bash", "coil"]:
				direct_to(Vector2())
			elif action != "dash":
				direct_to(get_map_path(target.position))
				rotate_to(target.position)
		else:
			direct_to(Vector2())

func interaction(origin, type, arg = null):
	if get_tree().is_network_server():
		if type in ["attack","shot"]:
			damage(origin, arg)
		elif type == "block":
			animation.call_reaction()
		elif type == "deflect":
			do("bash")

func coil():
	var side_collision = vision()
	if side_collision:
		dash(side_collision)
	elif !animation.get_action() and target.lock(1.3):
		#$Audio.play()
		do("coil",3)

func attack():
	charged = []
	do("attack",2)
	objective = target.position-position
