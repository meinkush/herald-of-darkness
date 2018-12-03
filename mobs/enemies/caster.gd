extends "res://mobs/mob_base.gd"

var spell_kwargs

func _ready():
	actions.hit_range = ["wait"]
	actions.close     = ["cast_ball"]
	actions.far       = ["cast_ball"]
	ring.inner        = 1
	ring.spacing      = 70

func _physics_process(delta):
	var collision = movement(Vector2())
	if is_network_master() and target:
		if !animation.get_action().begins_with("cast"):
			pass
			# direct_to(path(target.position))
		rotate_to(target.position)

func interaction(origin, type, arg = null):
	if get_tree().is_network_server():
		if type in ["attack","shot"]:
			damage(origin,arg)

func cast_area():
	if target.lock(1.9):
		spell_kwargs = {"spell":"area"}
		do("cast_area",1)
		direct_to(Vector2())

func cast_ball():
	if do("cast_ball"):
		spell_kwargs = {"spell":"ball", "speed":6, "dir": (target.position-position).normalized()}
		direct_to(Vector2())

func release():
	if is_network_master():
		if spell_kwargs["spell"] == "ball" and target:
			magic.cast(self,spell_kwargs["spell"],position,spell_kwargs)
		elif target:
			magic.cast(self,spell_kwargs["spell"],target.position,spell_kwargs)
