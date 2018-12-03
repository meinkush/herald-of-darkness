extends AnimationPlayer

var state = ""

func _ready():
	set_reactions()

func call_action(anim, force_on = []):
	var current_action = get_action()
	if !current_action or current_action in force_on:
		set_action(anim)
		return true
	else:
		return false

remote func set_action(anim):
	if is_network_master():
		rpc("set_action",anim)
	play(anim)

func get_action():
	if !current_animation in ["idle","run"]:
		return current_animation
	else:
		return ""

func get_length(anim = current_animation):
	return get_animation(anim).get_length()

func set_reactions():
	for animation in get_animation_list():
		if animation.ends_with("_r"):
			animation_set_next(animation.split("_")[0],animation)
