extends TileMap

var map

var current_room = 0

var mob_groups = {}

var connection_locked = [0,0]

var clue = load("res://objects/clue.tscn")

const INTERACTION_LAYER = 1

const PlAYER_LAYER = 2

const ENEMY_LAYER = 4

const WALL_LAYER = 8

# var ua = []
# var update = false
# func _draw():
# 	if update:
# 		draw_line( ua[0], ua[1], Color("#fff"))
# 		draw_line( ua[2], ua[3], Color("#fff"))

func room_change(character,room_connection, f_tile_pos, n_tile_pos, quadrant):
	if get_tree().is_network_server() and $door_lock.is_stopped():
		$door_lock.start()
		var new_room = current_room
		var boundary = cell_size.x
		var f1 = character.position + cell_size*quadrant*5
		var f2 = character.position - cell_size*quadrant*5
		var n1 = f_tile_pos + cell_size*5
		var n2 = f_tile_pos - cell_size*5
		if quadrant.x == quadrant.y:
			if quadrant.x < 0:
				n1 = f_tile_pos + cell_size*Vector2(-1,1)*5 + Vector2(cell_size.x,0)
				n2 = f_tile_pos - cell_size*Vector2(-1,1)*5 + Vector2(cell_size.x,0)
			else:
				n1 = f_tile_pos + cell_size*Vector2(-1,1)*5
				n2 = f_tile_pos - cell_size*Vector2(-1,1)*5
		else:
			if quadrant.x > 0:
				n1-=Vector2(cell_size.x,0)
				n2-=Vector2(cell_size.x,0)
		var l = Geometry.segment_intersects_segment_2d(f1,f2,n1,n2)
		var entrance = Vector2()
		if l and l.distance_to(character.position) < cell_size.length()/2:
			new_room = room_connection[0]
			entrance = f_tile_pos
		else:
			new_room = room_connection[1]
			entrance = n_tile_pos
		# if new_room != current_room:
		rpc("enter_room",new_room,entrance+Vector2(0,cell_size.y/2),character.get_network_master())
		# else:
		# 	see_room(new_room)
		# ua = [f1,f2,n1,n2]
		# update = true
		# update()

func populate(level):
	map = load("res://scenario/map_base.tscn").instance()
	map.build()
	add_child_below_node($UnderMarkers,map)
	for tile in map.tiles:
		set_cell(tile.x,tile.y,tile.z)
	for wall in map.walls:
		map.set_cell(wall.x,wall.y,1)
	# see_room(current_room)

func spawn_players(player_list):
	if get_tree().is_network_server():
		for player in player_list:
			rpc("spawn",map.get_room_center(current_room)+rot2vec2(rand_range(-PI, PI),randi()%50), "knight", player)
		# if get_tree().get_network_unique_id() == player:
		# 	$HUD.assign_character(new_char)
		# 	if OS.get_name() != "Android":
		# 		$HUD/RightPad.hide()
		# 		$HUD/LeftPad.hide()
		# new_char.add_to_group('players')

func spawn_enemies(spawner):
	if get_tree().is_network_server():
	# var spawners = trigger.get_children()
	# if !mob_groups.has(trigger.get_name()):
	# 	mob_groups[trigger.get_name()] = 0
	# for lock in $Actions.get_children():
	# 	if trigger.get_name() == lock.get_name():
	# 		lock.collision_layer = WALL_LAYER
		for spawn_point in spawner:
			rpc("spawn",spawn_point.transform[2], spawn_point.object)
		# mob.trigger = spawner
		# mob_groups[spawner] += 1

sync func spawn(new_pos, object, network_master = null):
	var new_obj = $ResourcePreloader.get_resource(object).instance()
	new_obj.position = new_pos
	map.add_child(new_obj)
	if network_master:
		new_obj.set_network_master(network_master)
	return new_obj

func dead_mob(mob):
	mob.remove_from_group("mobs")
	if get_tree().get_nodes_in_group("mobs").size() == 0:
		map.open_room(current_room)
	# mob_groups[mob.trigger] -= 1
	# if mob_groups[mob.trigger] < 1:
	# 	for lock in $Actions.get_children():
	# 		if mob.trigger == lock.get_name():
	# 			lock.collision_layer = 0

func next_scene(next):
	pass
  # var x = 0
  # for player in manager.get_player_characters():
  #   player.position = $Room/Spawners.get_children()[x].position
  #   x += 1

# func set_scenario(scenario):
# 	if level:
# 		level.queue_free()
# 	level = load('res://scenario/areas/'+scenario+'.tscn').instance()
# 	level.collision_layer = WALL_LAYER

remote func add_magic(res,kwargs,ref,sprite, pos):
	if get_tree().is_network_server():
		rpc("add_magic",res,kwargs,ref,sprite, pos)
	var magic = load(res).instance()
	magic.caster = ref
	if sprite:
		map.add_child(magic)
	else:
		$UnderMarkers.add_child(magic)
	for kwarg in kwargs:
		magic.set(kwarg,kwargs[kwarg])
	magic.position = pos

func _ready():
	collision_mask = WALL_LAYER

func _physics_process(delta):
	set_camera_position()


var slsh = Vector2()

func set_camera_position():
	$HUD.rect_position = $HUD.rect_position.linear_interpolate(map.get_room_center(current_room)-get_viewport().size/2/GameState.viewport_size+slsh,0.1)
	get_viewport().set_canvas_transform(Transform2D(Vector2(GameState.viewport_size,0),Vector2(0,GameState.viewport_size),$HUD.rect_position*-GameState.viewport_size))
	slsh = Vector2()

# func interaction(origin, type, arg = null):
# 	print("interaction() has not been set up for "+str(self))

func v2tov3(v2, depth = 0):
	return Vector3(v2[0], v2[1], depth)

func v3tov2(v3):
	return Vector2(v3[0],v3[1])

static func rot2vec2(rad,length):
	return Vector2(-length,0).rotated(rad)

func get_map_path(from, to):
	# var p = map.get_path(from,to)
	# if !p:
	# 	p = [to]
	# return p
	return [to]

remote func add_clue(c_pos, c_shape, c_bounds):
	if get_tree().is_network_server():
		rpc("add_clue",c_pos, c_shape, c_bounds)
	var new_clue = clue.instance()
	new_clue.position = c_pos
	new_clue.shape = c_shape
	new_clue.bounds = c_bounds
	$UnderMarkers.add_child(new_clue)

func see_room(room):
	current_room = room
	for tile in map.get_used_cells():
		map.set_cell(tile.x,tile.y,1)
	for wall in map.get_front_walls(room):
		map.set_cell(wall.x,wall.y,wall.z)

sync func enter_room(room, entrance_tile, peer):
	if get_tree().get_network_unique_id() != peer and current_room != room:
		for character in get_tree().get_nodes_in_group("players"):
			if character.get_network_master() == get_tree().get_network_unique_id():
				character.position = entrance_tile
	see_room(room)
	if map.rooms[current_room]["can_close"]:
		map.close_room(current_room)
		spawn_enemies(map.get_spawners(room))
