extends Timer

var particle

var strength = 1

export var damage_threshold = .2

var damage_time = 0

export var particle_threshold = .3

var particle_time = 0

var origin

func _physics_process(delta):
	if particle_time > particle_threshold:
		release_trail(get_node("../../").global_position)
		particle_time = 0
	else:
		particle_time += delta

func _ready():
	connect("timeout",self,"queue_free")

func release_trail(pos):
	var particle_ins = particle.instance()
	particle_ins.position = pos
	particle_ins.emitting = true
	get_node("/root/Scenario/tile_map").add_child(particle_ins)
