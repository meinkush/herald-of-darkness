extends Area2D

export var on_pressed = true

func _ready():
	$animation.animation_set_next("pressed","shoot")

func pressed(object):
	if on_pressed and !$animation.is_playing():
		$animation.play("pressed")

func shoot():
	$animation.play("shoot")

func hit():
	for object in get_overlapping_bodies():
		object.interaction(self, "attack", [1, ["bleed",[1,4]]])
