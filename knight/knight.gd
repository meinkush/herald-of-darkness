extends "res://OIT/KOB/character.gd"

sync var lock = 0

var stack = []

var rot_dir = Vector2()

var pressure = 1

var buffer

var move_dir = Vector2()

func _ready():
	add_to_group('players')
	animation = $animation
	collision_layer = PLAYER_LAYER

func _physics_process(delta):
	$aim.rotation = rot
	var action = animation.get_action()
	if move_dir and (action != "bash" or guard):
			direct_to(move_dir,speed*pressure)
	else:
		direct_to(Vector2())
	if buffer:
		if !Input.is_action_pressed(buffer):
			buffer = null
		elif call(buffer, true, rot_dir):
			buffer = null
	if !action in locked_animations:
		if dir and !guard:
			rotate_to(position +dir)
		else:
			rotate_to(rot_dir)
	if !animation.get_action() in locked_animations:
		movement(dir)
	else:
		movement(Vector2())
	if lock > 0:
		lock -= delta

func interaction(origin, type, arg = null):
	if get_tree().is_network_server():
		if type == "attack":
			if guard and abs(rot-(origin.position-position).angle()) > 1.5707965:
				do("block",0,["guard","guard_up"])
			elif animation.get_action() == "dash":
				return "avoid"
			else:
				if typeof(arg) == TYPE_ARRAY:
					damage(origin, arg[0],arg[1][0], arg[1][1])
				else:
					damage(origin, arg)
				return "contact"
		elif type == "push":
			if animation.get_action() != "deflect":
				if guard and abs(rot-(origin.position-position).angle()) > 1.5707965:
					push(arg[0],arg[1]/2)
				elif animation.get_action() != "dash":
					push(arg[0],arg[1])

func stack_append(mob):
	if !mob in stack:
		stack.append(mob)

func stack_erase(mob):
	if mob in stack:
		stack.erase(mob)

func lock(start_time):
	if lock <= 0:
		lock = start_time
		return true
	else:
		return false

func slash():
	$slash.position = rot2dir(f_rot,9)
	$slash.rotation = f_rot+PI
	$slash.show()
	$slash/AnimationPlayer.play("slash")

func sword(pressed, aim_dir):
	if pressed and (do("attack",1,["attack1_r"]) or do("attack1",1,["attack_r"])):
		rotate_to(aim_dir)
		return true

func shield(pressed, aim_dir):
	if !"shield" in $status.cooldown and pressed and do("guard_up",0,["attack", "attack_r","attack1", "attack1_r"]):
		set_guard(true)
		return true
	elif !pressed and animation.get_action() == "guard_up":
		do("stun_shield",0,["guard_up"])
		$status.set_cooldown("shield",3)
		set_guard(false)
		for object in get_interactables_in_front(35, ENEMY_LAYER):
			object.interaction(self,"push",[position, 10])
			object.interaction(self,"stun",[2])
	elif guard:
		do("idle",0,["guard"])
		set_guard(false)
		return true

sync func shoot():
	if get_tree().is_network_server():
		do("release",0,["aim"])
		var collision = get_interactable_in_line(position, rot2dir(rot,700)+position, ENEMY_LAYER+WALL_LAYER)
		if collision:
			collision.collider.interaction(self, "shot", 1)

func do(action, required_st = 0, force_on = []):
	if $status.st > 0 and animation.call_action(action,force_on):
		$status.stamina(-required_st)
		return true

func dash(d_dir):
	if !"dash" in $status.cooldown and do("dash",1,["attack","attack_r","attack1","attack_r1"]):
		push(position-d_dir,30)
		$status.set_cooldown("dash", .7)

func direct_to(new_dir, move_speed = speed):
	if guard:
		move_speed /= 2
	dir = new_dir.normalized()*move_speed

func breath():
	$body/breath.restart()

func hit():
	slash()
	for object in get_interactables_in_front(35, ENEMY_LAYER):
		object.interaction(self, "attack", strenght)
		get_node("/root/Scenario").slsh += Vector2(30,40)

func _input(event):
	if !event.is_echo():
		if event.is_action("left"):
			move_dir.x = (int(event.is_pressed())*2-int(Input.is_action_pressed("right")))*-1
		elif event.is_action("up"):
			move_dir.y = (int(event.is_pressed())*2-int(Input.is_action_pressed("down")))*-1
		elif event.is_action("right"):
			move_dir.x = int(event.is_pressed())*2-int(Input.is_action_pressed("left"))
		elif event.is_action("down"):
			move_dir.y = int(event.is_pressed())*2-int(Input.is_action_pressed("up"))
		if move_dir.x and move_dir.y:
			move_dir = Vector2(64*sign(move_dir.x),32*sign(move_dir.y))
		if event.is_action("sword") and event.is_pressed() and !sword(event.is_pressed(), rot_dir):
			buffer = "sword"
		elif event.is_action("shield") and !shield(event.is_pressed(), rot_dir):
			buffer = "shield"
		elif event.is_action("dash") and event.is_pressed():
			if dir:
				dash(dir)
			else:
				dash(rot_dir-position)
		elif event is InputEventMouseMotion:
			rot_dir = get_node("/root/Scenario/HUD").rect_position+event.position/GameState.viewport_size
