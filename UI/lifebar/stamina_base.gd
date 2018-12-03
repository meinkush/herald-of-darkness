extends Node2D

var character

func _ready():
	character = get_parent()
	character.connect("status_update",self,"update")

func _draw():
	draw_rect(Rect2(Vector2(-character.max_st/2,0),Vector2(character.max_st,1)),Color("dddddd"))
	draw_rect(Rect2(Vector2(-character.max_st/2,0),Vector2(character.st,1)),Color("FFF121"))
