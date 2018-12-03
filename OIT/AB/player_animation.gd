extends 'res://OIT/AB/char_animation_base.gd'

func _process(delta):
	if character.guard:
		call_action('guard')
