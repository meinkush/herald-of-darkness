extends Area2D

var connection = []

var from_tile = Vector2()

var to_tile = Vector2()

var quadrant = Vector2()

func _ready():
	connect("body_exited",get_node("../../"),"room_change",[connection,from_tile,to_tile,quadrant])

func close():
	var shape = $shape
	remove_child(shape)
	$close.add_child(shape)
	$pivot/animation_player.play("close")

func open():
	var shape = $close/shape
	$close.remove_child(shape)
	add_child(shape)
	$pivot/animation_player.play("open")

func set_shape(f_tile,t_tile,cell_size):
	quadrant = find_quadrant(f_tile.angle_to_point(t_tile))
	if quadrant.x != quadrant.y:
		$pivot/sprite.flip_h = true
		if quadrant.x < 0:
			$pivot.position = Vector2(cell_size.x,0)
	else:
		if quadrant.x > 0:
			$pivot.position = cell_size/2
		# else:
		# 	$pivot.position = cell_size/2
	$shape.shape = portal.new(quadrant,cell_size)
	from_tile = f_tile
	to_tile = t_tile

func find_quadrant(angle):
	var quad = Vector2(1,1)
	if angle > 0:
		quad.y = -1
	if abs(angle) < PI/2:
		quad.x = -1
	return quad

class portal:
	extends SegmentShape2D

	func _init(quadrant,cell_size):
		if quadrant.x > 0:
			if quadrant.y < 0:
				a = Vector2(0,0)
				b = Vector2(cell_size.x/2,cell_size.y/2)
			else:
				a = Vector2(cell_size.x/2,cell_size.y/2)
				b = Vector2(0,cell_size.y)
		else:
			if quadrant.y < 0:
				a = Vector2(0,0)
				b = Vector2(-cell_size.x/2,cell_size.y/2)
			else:
				a = Vector2(-cell_size.x/2,cell_size.y/2)
				b = Vector2(0,cell_size.y)
