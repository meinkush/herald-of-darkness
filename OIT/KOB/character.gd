extends "res://OIT/KOB/movement.gd"

# func _process(delta):
# 	$Label.text = animation.get_action()

#-----------------------------------------

var locked_animations = ["attack","attack_r","attack1","attack1_r","dash","bash",]

export var strenght = 0

export var dexterity = 0

export var intelligence = 0

var animation

var guard = false

onready var magic = preload("res://objects/magic_base.gd")

func _ready():
	collision_layer = INTERACTION_LAYER
	collision_mask = WALL_LAYER

slave func set_rot(n_rot):
	rot = n_rot
	if abs(rot) > 1.5707965:
		$body.scale.x = 1
	else:
		$body.scale.x = -1

func attack():
	do("attack",1)

func dash(d_dir):
	if do("dash"):
		d_dir = rot2dir(d_dir.angle())
		push(position+d_dir,30)
		rotate_to(position+drag_dir)

#TODO add type of damage
func damage(origin, amount, type = "basic", trail_data = null):
	animation.set_action("bash")
	set_guard(false)
	$status.damage(-amount, type, trail_data)

func hit():
	for object in get_interactables_in_front(100, INTERACTION_LAYER):
		object.interaction(self, "attack", strenght)

func do(action, required_st = 0, force_on = []):
	if animation.call_action(action,force_on):
		$status.stamina(-required_st)
		return true

func die():
	set_physics_process(false)
	animation.set_action("dead")

remote func set_guard(mode):
	if is_network_master():
		rpc("set_guard",mode)
	guard = mode
