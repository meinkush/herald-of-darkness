extends "res://shaders&particles/states/trail_base.gd"

func _ready():
	particle = preload("res://shaders&particles/states/bleed.tscn")

func _physics_process(delta):
	if get_node("../../").f_dir:
		if damage_time > damage_threshold:
			get_node("../").damage(-strength,"bleed")
			damage_time = 0
			release_trail(get_node("../../").global_position)
			particle_time = 0
		else:
			damage_time += delta

func release_trail(pos):
	var particle_ins = particle.instance()
	particle_ins.position = pos
	particle_ins.emitting = true
	get_node("/root/Scenario/UnderMarkers").add_child(particle_ins)
