extends Area2D

export var loop = false

export var on_pressed = true

func _ready():
	$animation.animation_set_next("light_up","spit")

func pressed(object):
	if on_pressed and !$animation.is_playing():
		$animation.play("light_up")

func spit():
	if !$animation.is_playing():
		$animation.play("light_up")

func cease():
	$animation.play("cease")

func hit():
	for object in get_overlapping_bodies():
		object.interaction(self, "attack", [1, ["burn",[2,3]]])

func _animation_finished(animation):
	if animation in ["spit","idle"]:
		if loop:
			$animation.play("idle")
		else:
			$animation.play("cease")
