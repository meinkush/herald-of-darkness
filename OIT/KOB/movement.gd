extends "res://OIT/KOB/interact.gd"

export var speed = 0.0

sync var f_dir = Vector2()

sync var drag_dir = Vector2()

var f_rot = 0

var dir = Vector2()

var speed_mod = 1

export var weigth = .85

func movement(m_dir):
	if is_network_master():
		# rot = wrapf(rot,-PI,PI)
		if f_rot-rot > PI:
			rot += PI*2
		elif f_rot-rot < -PI:
			rot -= PI*2
		set_rot(rot+(f_rot-rot)*.4)
		rpc_unreliable("set_position", position)
		rpc_unreliable("set_rot",rot)
		rset_unreliable("f_dir", m_dir*speed_mod)
		rset_unreliable("drag_dir", drag_dir*weigth)
	return move_and_slide(((f_dir)+drag_dir)*30)

func direct_to(new_dir, move_speed = speed):
	dir = new_dir.normalized()*move_speed

func push(origin, strength):
	drag_dir += to_local(origin).normalized()*-strength

func rotate_to(new_dir):
	f_rot = position.angle_to_point(new_dir)

slave func set_rot(n_rot):
	rot = n_rot

slave func set_position(n_pos):
	position = n_pos

func rot2dir(angle, length = 1):
	return Vector2(-length,0).rotated(angle)
