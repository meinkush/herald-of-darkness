extends TileMap

var room_list = ["room2","room3","room4","sp00ky_room"]

var rooms = []

var constrains = [0,0,0,0]

var tiles = PoolVector3Array()

var permanent_walls = {}

var walls = {}

var astar = AStar.new()

var room_base = preload("res://scenario/areas/room_base.tscn")

var door_base = preload("res://scenario/tiles/door.tscn")

var spike = preload("res://scenario/tiles/traps/spikes.tscn")

var column = preload("res://scenario/tiles/column.tscn")

const INTERACTION_LAYER = 1

const PlAYER_LAYER = 2

const ENEMY_LAYER = 4

const WALL_LAYER = 8

func build():
	collision_layer = WALL_LAYER
	mode = MODE_ISOMETRIC
	cell_size = Vector2(64,32)
	var f_room = load("res://scenario/areas/1/room1.tscn").instance()
	add_room_to_map(f_room,Vector2())
	var i = 0
	for r in room_list:
		var rad = 3
		var room = load("res://scenario/areas/1/"+r+".tscn").instance()
		while !add_room_to_map(room,rot2vec2(rand_range(-PI, PI),rad).floor()+rooms[i]["center"]):
			rad += 1
		i += 1
	for room in rooms.size()-1:
		connect_rooms(room,room+1)
	# build_navigation()
	build_walls()
	# update()

# func _draw():
# 	for point in astar.get_points():
# 		# draw_circle(v3tov2(astar.get_point_position(point)),3,Color("#fff"))
# 		for con in astar.get_point_connections(point):
# 			draw_line(v3tov2(astar.get_point_position(point)),v3tov2(astar.get_point_position(con)), Color("#fff"))

func connect_rooms(room_from,room_to):
	var path = get_hall_path(room_from, room_to)
	if path.size() < 3:
		print("can't connect "+str(room_from)+" to "+str(room_to))
		return
	var hall = room_base.instance()
	var f_path = PoolVector2Array()
	for index in path.size():
		var tile = v3tov2(path[index])
		if tile in rooms[room_from]["tiles"] and path.size() > index+1 and v3tov2(path[index+1]) in rooms[room_from]["tiles"]:
			continue
		elif tile in rooms[room_to]["tiles"] and index-1 >= 0 and v3tov2(path[index-1]) in rooms[room_to]["tiles"]:
			continue
		else:
			f_path.append(tile)
	var entrance = make_door(f_path,[room_from,rooms.size()])
	f_path.invert()
	var exit = make_door(f_path,[room_to,rooms.size()])
	add_child(entrance)
	add_child(exit)
	f_path.remove(0)
	f_path.remove(f_path.size()-1)
	for tile in f_path:
		hall.set_cell(tile.x,tile.y,0)
	add_room_to_map(hall,Vector2(),true)
	rooms[room_from]["doors"].append(entrance)
	rooms[room_to]["doors"].append(exit)
	rooms.back()["doors"].append(entrance)
	rooms.back()["doors"].append(exit)
	# rooms[room_from]["connections"][from_tile] = f_path.front()
	# rooms[room_to]["connections"][to_tile] = f_path.back()

func get_hall_path(room_from,room_to):
	var id = 0
	var free_tiles = {}
	var path = AStar.new()
	for x in range(constrains[0],constrains[2]+1):
		for y in range(constrains[1],constrains[3]+1):
			if get_tile_owner(Vector2(x,y)) < 0 or rooms[room_from]["tiles"].has(Vector2(x,y)) or rooms[room_to]["tiles"].has(Vector2(x,y)):
				var weight = 1
				if get_tile_owner(Vector2(x,y)) < 0:
					if walls.has(Vector2(x,y)):
						weight += 20
					else:
						weight += 1
				path.add_point(id,Vector3(x,y,0),weight)
				free_tiles[Vector2(x,y)] = id
				for tile in get_surrounding_tiles(Vector2(x,y),true):
						if free_tiles.has(tile):
							path.connect_points(id,free_tiles[tile])
				id +=1
	return path.get_point_path(free_tiles[rooms[room_from]["center"]],free_tiles[rooms[room_to]["center"]])

func make_door(path,connection):
	var index = 0
	while index < path.size()-2 and get_surrounding_tiles(path[index+1],true,true).size() > 1:
		index += 1
	var d = door_base.instance()
	d.set_shape(map_to_world(path[index]),map_to_world(path[index+1]),cell_size)
	d.position = map_to_world(path[index])
	d.connection = connection
	return d

func add_room_to_map(room, r_constrains, is_hall = false):
	var room_tiles = []
	var spawners = []
	var objects = []
	var center = find_center(room,r_constrains)
	if rooms.size() == 0:
		var f_tile = room.get_used_cells()[0]
		constrains = [f_tile.x-4,f_tile.y-4,f_tile.x+4,f_tile.y+4]
	for tile in room.get_used_cells():
		tile += r_constrains
		if is_tile_free(tile,false,is_hall):
			room_tiles.append(tile)
		elif !is_hall:
			return false
	var name_compare = {}
	var animation_player
	for child in room.get_children():
		var old_name = child.get_name()
		room.remove_child(child)
		add_child(child)
		name_compare[old_name] = child.get_name()
		if old_name == "animation_player":
			animation_player = child
		else:
			if old_name.begins_with("Spawner"):
				spawners.append(child)
			child.position += map_to_world(r_constrains)
			objects.append(child)
	if animation_player:
		for animation in animation_player.get_animation_list():
			for track in animation_player.get_animation(animation).get_track_count():
				var track_path = animation_player.get_animation(animation).track_get_path(track)
				if track_path in name_compare.keys():
					animation_player.get_animation(animation).track_set_path(track,NodePath(name_compare[String(track_path)]))
	for tile in room_tiles:
		for t in get_surrounding_tiles(tile):
			if walls.has(t):
				walls[t].append(rooms.size())
			else:
				walls[t] = [rooms.size()]
		tile = Vector3(tile.x,tile.y,room.get_cell(tile.x-r_constrains.x,tile.y-r_constrains.y))
		tiles.append(tile)
		if tile.x-4 < constrains[0]:
			constrains[0] = tile.x-4
		elif tile.x+4  > constrains[2]:
			constrains[2] = tile.x+4
		if tile.y-4  < constrains[1]:
			constrains[1] = tile.y-4
		elif tile.y+4  > constrains[3]:
			constrains[3] = tile.y+4
		if tile.z == 2:
			var found = false
			var spike_pos = map_to_world(Vector2(tile.x,tile.y))+Vector2(0,cell_size.y)/2
			for obj in objects:
				if obj.position == spike_pos:
					found = true
					break
			if !found:
				var s = spike.instance()
				s.position = spike_pos
				add_child(s)
				objects.append(s)
	rooms.append({
	"can_close":room.can_close,
	"tiles":room_tiles,
	"center":center,
	"global_center":map_to_world(center)+Vector2(cell_size.x,0)/2,
	"objects":objects,
	"spawners":spawners,
	# "connections":{},
	"doors":[]})
	return true

func build_navigation():
	astar.clear()
	var free_tiles = {}
	var i = 0
	for tile in tiles:
		var pos = map_to_world(tile)
		astar.add_point(i,Vector3(pos.x,pos.y+cell_size.y/2,pos.z))
		free_tiles[tile] = i
		i+=1
	for room in rooms:
		for tile in room["tiles"]:
			for srd in get_surrounding_tiles(tile,true):
				if srd in free_tiles and (srd in room["tiles"] or v2tov3(srd) in room["connections"].values()):
					astar.connect_points(free_tiles[tile],free_tiles[srd])

func build_walls():
	var t = get_floor_tiles()
	for wall in walls.keys():
		if wall in t:
			walls.erase(wall)

func get_surrounding_tiles(tile,cross = false, in_map = false):
	var surroundings = []
	for y in range(-1,2):
		for x in range(-1,2):
			if Vector2(x,y):
				var t = get_floor_tiles()
				if cross and x in [-1,1] and y in [-1,1]:
					continue
				elif in_map and !tile+Vector2(x,y) in t:
					continue
				else:
					surroundings.append(Vector2(x,y)+tile)
	return surroundings

func get_front_walls(room):
	var wall_map = []
	for wall in walls:
		if room in walls[wall]:
			for tile in get_surrounding_tiles(wall):
				if room == get_tile_owner(tile) and map_to_world(tile).y < map_to_world(wall).y:
					wall_map.append(Vector3(wall.x,wall.y,3))
	return wall_map

func find_center(room,room_pos):
	var left = room.get_used_cells()[0].x
	var right = room.get_used_cells()[0].x
	var top = room.get_used_cells()[0].y
	var bottom = room.get_used_cells()[0].y
	for tile in room.get_used_cells():
		if tile.x < left:
			left = tile.x
		elif tile.x > right:
			right = tile.x
		if tile.y < top:
			top = tile.y
		elif tile.y > bottom:
			bottom = tile.y
	return ((Vector2(left,top)+Vector2(right,bottom)+Vector2(1,1))/2).floor()+room_pos

func get_room_center(room):
	return rooms[room]["global_center"]

func get_spawners(room):
	return rooms[room]["spawners"]

func get_floor_tiles():
	var floor_tiles = PoolVector2Array()
	for tile in tiles:
		floor_tiles.append(Vector2(tile.x,tile.y))
	return floor_tiles

func get_tile_owner(tile):
	for room in rooms.size():
		if tile in rooms[room]["tiles"]:
			return room
	return -1

func get_map_path(from_pos,to_pos):
	var path = PoolVector2Array()
	for node in astar.get_point_path(astar.get_closest_point(Vector3(from_pos.x,from_pos.y,0)),astar.get_closest_point(Vector3(to_pos.x,to_pos.y,0))):
		path.append(Vector2(node.x,node.y))
	return path

func is_tile_free(tile, cross = false, only_used = false):
	var t = get_floor_tiles()
	if only_used:
		if tile in t:
			return false
	else:
		for sur in get_surrounding_tiles(tile,cross):
			if sur in t or sur in walls:
				return false
	return true

func close_room(room):
	for door in rooms[room]["doors"]:
		door.close()

func open_room(room):
	for door in rooms[room]["doors"]:
		door.open()

func rot2vec2(rad,length):
	return Vector2(-length,0).rotated(rad)

func v2tov3(v2, depth = 0):
	return Vector3(v2[0], v2[1], depth)

func v3tov2(v3):
	return Vector2(v3[0],v3[1])

# func interaction(origin, type, arg = null):
# 	print("interaction() has not been set up for "+str(self))
