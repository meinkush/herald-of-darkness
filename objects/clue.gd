extends Node2D

var shape = ""

var bounds = []

func _ready():
	update()

func _draw():
	draw_circle(Vector2(), bounds[0], Color("d80000"))
