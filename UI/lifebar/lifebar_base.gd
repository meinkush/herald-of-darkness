extends Node2D

var character

func _ready():
	character = get_parent()
	character.connect("status_update",self,"update")

func _draw():
	draw_rect(Rect2(Vector2(-character.max_hp/2,0),Vector2(character.max_hp,1)),Color("d80000"))
	draw_rect(Rect2(Vector2(-character.max_hp/2,0),Vector2(character.hp,1)),Color("5bff00"))
