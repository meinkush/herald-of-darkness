extends KinematicBody2D

const INTERACTION_LAYER = 1

const PLAYER_LAYER = 2

const ENEMY_LAYER = 4

const WALL_LAYER = 8

var rot = 0

var area

var area_shape

var front

var front_shape

func _ready():
  collision_layer = 0
  collision_mask = 0
  area = Physics2DShapeQueryParameters.new()
  area_shape = CircleShape2D.new()
  area.set_shape(area_shape)
  front = Physics2DShapeQueryParameters.new()
  front_shape = RectangleShape2D.new()
  front.set_shape(front_shape)

func interaction(origin, type, arg = null):
	if get_tree().is_network_server():
		deferred_interaction(origin,type,arg)

func deferred_interaction(origin,type,arg):
	print("deferred_interaction() has not been set up for "+str(self))

func get_interactables(radius, layer, ignore = []):
  ignore.append(self)
  area.collision_layer = layer
  area_shape.set_radius(radius)
  area.transform.origin = position
  var interactables = []
  for interactable in get_world_2d().direct_space_state.intersect_shape(area):
    if !interactable["collider"] in ignore and interactable["collider"]:
      interactables.append(interactable["collider"])
  return interactables

func get_interactables_in_front(radius, layer, ignore = []):
  var in_area = get_interactables(radius, layer, ignore)
  front.collision_layer = layer
  front_shape.extents = Vector2(radius/2,radius)
  front.transform = Transform2D(rot,position).translated(Vector2(-radius/2,0))
  var interactables = []
  for interactable in get_world_2d().direct_space_state.intersect_shape(front):
    if interactable["collider"] in in_area:
      interactables.append(interactable["collider"])
  # print(interactables)
  return interactables

func get_interactable_in_line(origin, objective, layer, ignore = []):
	ignore.append(self)
	# test.append([origin,objective])
	var collision = get_world_2d().get_direct_space_state().intersect_ray(origin,objective,ignore,layer)
	return collision

# func _physics_process(delta):
# 	update()
#
# var test = []
# func _draw():
# 	for line in test:
# 		draw_line(line[0]-position,line[1]-position, Color("#fff"))
# 		test.clear()
