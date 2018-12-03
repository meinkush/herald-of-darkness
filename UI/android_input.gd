extends Node

static func _input(event):
	if OS.get_name() != "Android":
		if event.is_action("sword") and !character.sword():
			buffer = "sword"
			if !event.is_pressed():
				buffer = "release"
			elif event is InputEventMouseButton:
				character.rotate_to((event.position - get_viewport().size/2)+character.position)
		elif event.is_action("shield") and !character.shield():
			buffer = "shield"
			if !event.is_pressed():
				buffer = "release"
			elif event is InputEventMouseButton:
				character.rotate_to((event.position - get_viewport().size/2)+character.position)
		elif event.is_action("bow") and !character.bow():
			buffer = "bow"
			if !event.is_pressed():
				buffer = "release"
			elif event is InputEventMouseButton:
				character.rotate_to((event.position - get_viewport().size/2)+character.position)
		elif event.is_action("dash"):
			buffer = "dash"
			if !event.is_pressed():
				buffer = "release"
			elif event is InputEventMouseButton:
				character.rotate_to((event.position - get_viewport().size/2)+character.position)
	if event is InputEventScreenTouch:
		if event.is_pressed():
			# if !left_stick(event) and acting < 0:
				for item in items:
					if item.is_pressed():
						buffer = item.get_name()
						acting = event.index
						selected_item = item
						break
		else:
			if event.index == moving:
				moving = -1
				stick_pressure = 0
				$LeftPad/Pad/Stick.hide()
			elif event.index == acting:
				acting = -1
				buffer = "release"
	elif event is InputEventMouseMotion and character.aim and acting < 0:
		character.rotate_to((event.position - get_viewport().size/2)+character.position)
	elif event is InputEventScreenDrag:
		if !left_stick(event) and character.aim:
			character.rotate_to(selected_item.get_node("Position").make_input_local(event).position+character.position)
	if !event.is_echo():
		if event.is_pressed():
			if event.is_action("left"):
				stick_pressure = 1
				dir.x = -1
			elif event.is_action("right"):
				stick_pressure = 1
				dir.x = 1
			elif event.is_action("up"):
				stick_pressure = 1
				dir.y = -1
			elif event.is_action("down"):
				stick_pressure = 1
				dir.y = 1
		elif event.is_action("left") or event.is_action("right"):
			dir.x = 0
			if Input.is_action_pressed("left"):
				stick_pressure = 1
				dir.x = -1
			elif Input.is_action_pressed("right"):
				stick_pressure = 1
				dir.x = 1
		elif event.is_action("up") or event.is_action("down"):
			dir.y = 0
			if Input.is_action_pressed("up"):
				stick_pressure = 1
				dir.y = -1
			elif Input.is_action_pressed("down"):
				stick_pressure = 1
				dir.y = 1
	if event is InputEventJoypadMotion and Vector2(Input.get_joy_axis(0, JOY_ANALOG_LX), Input.get_joy_axis(0, JOY_ANALOG_LY)).length() > 0.3:
		dir = Vector2(Input.get_joy_axis(0, JOY_ANALOG_LX), Input.get_joy_axis(0, JOY_ANALOG_LY))
		character.rotate_to(dir+character.position)
		stick_pressure = Vector2(Input.get_joy_axis(0, JOY_ANALOG_LX), Input.get_joy_axis(0, JOY_ANALOG_LY)).length()
	elif event is InputEventJoypadMotion:
		stick_pressure = 0
	if event is InputEventJoypadMotion and Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY)).length() > 0.3:
		var direction = Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY))
		character.rotate_to(direction+character.position)

# func left_stick(event):
# 	event = $LeftPad/Pad.make_input_local(event)
# 	if event.position.length() < pad_radius+40 and moving < 0:
# 		moving = event.index
# 		$LeftPad/Pad/Stick.show()
# 	if moving == event.index:
# 		stick_pressure = $LeftPad/Pad/Stick.position.length()/pad_radius
# 		dir = event.position
# 		update_stick_position(Vector2(),$LeftPad/Pad/Stick,event.position)
# 		return true
#
# func update_stick_position(center, stick,n_pos, radius = pad_radius):
# 	if n_pos.length() > radius:
# 		stick.position = center + n_pos.normalized()*radius
# 	else:
# 		stick.position = center+n_pos
