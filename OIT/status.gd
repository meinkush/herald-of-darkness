extends Node2D

onready var damage_particle_packed = preload("res://shaders&particles/states/damage.tscn")

onready var damage_materials  = {
"basic": preload("res://shaders&particles/states/basic_damage.tres"),
"burn": preload("res://shaders&particles/states/burn_damage.tres"),
"poison": preload("res://shaders&particles/states/poison_damage.tres"),
"bleed": preload("res://shaders&particles/states/bleed_damage.tres"),
}

onready var trails  = {
"burn": preload("res://shaders&particles/states/burn_trail.tscn"),
"poison": preload("res://shaders&particles/states/poison_trail.tscn"),
"bleed": preload("res://shaders&particles/states/bleed_trail.tscn"),
}

onready var numbers_txt = [
preload("res://textures/numbers/0.png"),
preload("res://textures/numbers/1.png"),
preload("res://textures/numbers/2.png"),
preload("res://textures/numbers/3.png"),
preload("res://textures/numbers/4.png"),
preload("res://textures/numbers/5.png"),
preload("res://textures/numbers/6.png"),
preload("res://textures/numbers/7.png"),
preload("res://textures/numbers/8.png"),
preload("res://textures/numbers/9.png"),]

onready var stun_packed = preload("res://shaders&particles/states/stun.tscn")

onready var character = get_node("../")

var max_hp = 0

export var hp = 0

var max_st = 0

var weak = false

export var st = 0

var cooldown = {}

var moddifiers = {
"speed_mod" : 1,
}

var stun = null

signal status_update()

signal die()

func _ready():
	set_status(hp,st)
	connect("die",character,"die")

func _process(delta):
	for cd in cooldown:
		cooldown[cd] -= delta
		if cooldown[cd] <= 0:
			cooldown.erase(cd)
	if !"stamina" in cooldown:
		stamina(1)
	if weak:
		if st > max_st/4:
			weak = false

remote func stunned(time):
	if is_network_master():
		rpc("stun",time)
	if stun:
		if stun.get_node("timer").time_left < time:
			stun.get_node("timer").wait_time = time
			stun.get_node("timer").start()
	else:
		stun = stun_packed.instance()
		stun.get_node("timer").wait_time = time
		stun.get_node("timer").connect("timeout",self,"end_stun")
		character.animation.play("idle")
		character.speed_mod = 0

func end_stun():
	stun.queue_free()
	stun = null
	character.speed_mod = moddifiers["speed_mod"]

remote func add_trail(type,strength,time):
	if is_network_master():
		rpc("add_trail",type,time)
	var trail = trails[type].instance()
	trail.wait_time = time
	trail.strength = strength
	trail.origin = self
	add_child(trail)
	return trail

func debuff(stat,value):
	if !moddifiers.has_key(stat):
		moddifiers[stat] = character.get(stat)
	moddifiers[stat] += value
	if stat == "speed_mod" and stun:
		return
	character.set(stat,clamp(moddifiers[stat],0,abs(moddifiers[stat])))

func set_cooldown(ability, amount):
	cooldown[ability] = amount

remote func damage(amount,type = "basic", trail_data = null):
	if is_network_master():
		rpc("damage",amount,type)
		hitpoints(amount)
	amount = abs(amount)
	var total_damage = []
	while !total_damage.size() or amount > 9:
		var iteration_damage = amount%int(pow(10,total_damage.size()+1))
		amount -= iteration_damage
		total_damage.append(iteration_damage/pow(10,total_damage.size()))
	var p = 0
	total_damage.invert()
	for i in total_damage:
		var dmg = damage_particle_packed.instance()
		dmg.process_material = damage_materials[type]
		dmg.position.x = (total_damage.size()*-7/2)+7*p
		dmg.position += global_position
		dmg.texture = numbers_txt[i]
		get_node("/root/Scenario/OverMarkers").add_child(dmg)
		if trail_data:
			add_trail(type,trail_data[0],trail_data[1])
		dmg.emitting = true
		p+=1

func hitpoints(amount):
	rpc("update_hp",clamp(hp + amount, 0, max_hp))
	if hp:
		return true
	else:
		emit_signal("die")
		for child in get_children():
			child.set_physics_process(false)
		return false

func stamina(amount):
	rpc("update_st",clamp(st + amount, 0, max_st))
	if !st:
		weak = true
		set_cooldown("stamina",3)
	else:
		set_cooldown("stamina",.5)

sync func set_hp(new_hp):
	max_hp = new_hp
	hp = new_hp
	rpc("update_hp",new_hp)

sync func set_st(new_st):
	max_st = new_st
	st = new_st
	rpc("update_st", st)

sync func update_hp(n_hp):
	hp = n_hp
	emit_signal("status_update")

sync func update_st(new_st):
	st = new_st
	emit_signal("status_update")

func reset_st():
	rpc("update_st", max_st)

func reset_hp():
	rpc("update_hp", max_hp)

func set_status(new_hp, new_st = 0):
	rpc("set_hp",new_hp)
	rpc("set_st",new_st)

# var lifebar = preload("res://UI/lifebar/stamina_base.tscn")
#
# func set_status_bar(new_bar):
# 	var lb = lifebar.instance()
# 	add_child(lb)
# 	set_status_bar(lb)
# 	connect("status_update",new_bar,"update")
# 	new_bar.character = self
# 	emit_signal("status_update")
