extends "res://OIT/KOB/character.gd"

var target

var actions = {"hit_range":null,"close":null,"far":null}

var ring = {"inner":0,"spacing":0}

var path = []

var wait_time = 1

var stuck = false

var trigger
#-------------------------------------------------------------character controls

func _ready():
	animation = get_node("body/animation")
	animation.character = self
	collision_layer = ENEMY_LAYER
	collision_mask = WALL_LAYER
	$status.connect("die",get_node("/root/Scenario"),"dead_mob",[self])
	add_to_group("mobs")
	if is_network_master():
		$timer.connect("timeout",self,"_act")
		$timer.start()
		find_target()

func _act(buffer = null):
	if is_network_master() and !$status.stun:
		$timer.wait_time = wait_time+randf()
		if buffer:
			if buffer != "wait":
				call(buffer)
			else:
				wait(1)
		elif target:
			# TODO: fix to detect walls and just give a state as enum
			check_stuck()
			if get_interactables_in_front(100, PLAYER_LAYER).has(target):
				_act(actions.hit_range[randi() % actions.hit_range.size()])
			elif position.distance_to(target.position) < ring.inner+ring.spacing:
				_act(actions.close[randi() % actions.close.size()])
			else:
				_act(actions.far[randi() % actions.far.size()])
		else:
			find_target()

func dash(side = 0):
	if do("dash",2):
		if side:
			direct_to((target.position - position).rotated(1.570796*side), speed*1.5)
		else:
			direct_to((target.position - position).rotated(1.570796*sign(rand_range(-1, 1))),speed*1.5)

func vision():
	var left = Vector2($shape.shape.radius,0).rotated(rotation+1.570796)
	left = get_world_2d().get_direct_space_state().intersect_ray(position+left,target.position+left,[self],1025)
	if left and left.collider != target:
		return 1
	var right = Vector2($shape.shape.radius,0).rotated(rotation-1.570796)
	right = get_world_2d().get_direct_space_state().intersect_ray(position+right,target.position+right,[self],1025)
	if right and right.collider != target:
		return -1
	return 0

func find_target():
	var agroed = get_tree().get_nodes_in_group("players")[0]
	for player in get_tree().get_nodes_in_group("players"):
		if player.stack.size() < agroed.stack.size() or player.stack.size() == agroed.stack.size() and int(position.distance_to(player.position)) < int(position.distance_to(agroed.position)):
			agroed = player
	target = agroed
	# rset("target",agroed)
	target.stack_append(self)

func get_map_path(objective):
	if !stuck:
		var distance = position.distance_to(objective)
		if distance > ring.inner+ring.spacing:
			objective = (objective - position).normalized()
		elif distance < ring.inner:
			objective = (position - objective).normalized()
		else:
			objective = Vector2()
		for object in get_interactables($shape.shape.radius,ENEMY_LAYER+PLAYER_LAYER):
			objective -= (object.position-position).normalized()
		path = [objective]
		return objective
	elif path.size() <= 1:
		path = build_path(objective)
	elif position.distance_to(path[0]) < 16 and path.size() > 1:
		path.remove(0)
		check_stuck()
		return get_map_path(objective)
	var ndir = path[0]
	for mob in get_interactables($shape.shape.radius, ENEMY_LAYER):
		ndir = ndir.rotated(-position.angle_to(mob.position))
	return to_local(path[0])

func die():
	if target:
		target.stack_erase(self)
	$timer.stop()
	set_physics_process(false)
	animation.set_action("dead")
	collision_layer = 0
	# remove_from_group("mobs")
	# queue_free()

func deferred_interaction(origin, type, arg):
	if type == "stun":
		$status.stunned(arg[0])

func wait(time):
	$timer.wait_time = time
	$timer.start()

func build_path(target_pos):
	return get_node("/root/Scenario").get_map_path(position, target_pos)

func check_stuck():
	var l = rot2dir(rot+1.570796, $shape.shape.radius)
	var r = rot2dir(rot-1.570796, $shape.shape.radius)
	stuck = (get_interactable_in_line(position,target.position,WALL_LAYER) or get_interactable_in_line(position+l,target.position+l,WALL_LAYER) or get_interactable_in_line(position+r,target.position+r,WALL_LAYER))

# var test = []
# func _draw():
	# if test:
	# 	draw_line(Vector2(), (test[1]-position).normalized()*test[2], Color("#fff"))
	# for node in range(path.size()):
	# 	if node != 0:
	# 		draw_line(path[node-1]-position, path[node]-position, Color("#fff"))

func explode():
	$body/explosion.restart()
	$body/shadow.visible = false
	# $LifeBar.visible = false
# func damage(origin, amount):
# 	do("bash")
# 	set_guard(false)
# 	hitpoints(-amount)
