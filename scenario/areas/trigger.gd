extends Area2D

func _ready():
	connect("body_entered",get_node("../../"),"_trigger",[self])

# sync func trigger():
# 	if is_network_master():
# 		get_node("../../")._trigger(self)
