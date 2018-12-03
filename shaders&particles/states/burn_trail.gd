extends "res://shaders&particles/states/trail_base.gd"

func _ready():
	particle = preload("res://shaders&particles/states/burn.tscn")

func _physics_process(delta):
	if damage_time > damage_threshold:
		get_node("../").damage(-strength,"burn")
		damage_time = 0
	else:
		damage_time += delta

func release_trail(pos):
	var particle_ins = particle.instance()
	particle_ins.emitting = true
	origin.add_child(particle_ins)
