extends Node

static func cast(caster,spell,position,kwargs = {}):
	if caster.get_tree().is_network_server():
		var magic
		if spell == 'ball':
			caster.get_node('/root/Scenario').add_magic('res://objects/magic_ball.tscn', kwargs, weakref(caster),true,position)
			# magic = load('res://objects/magic_ball.tscn').instance()
			# caster.get_node('/root/Scenario/textures').add_child(magic)
		else:
			caster.get_node('/root/Scenario').add_magic('res://objects/magic_area.tscn', kwargs, weakref(caster),false,position)
			# magic = load('res://objects/magic_area.tscn').instance()
			# caster.get_node('/root/Scenario/UnderMarkers').add_child(magic)
		# magic.caster = weakref(caster)
		# for kwarg in kwargs:
		# 	magic.set(kwarg,kwargs[kwarg])
		# magic.position = position
		# return magic
