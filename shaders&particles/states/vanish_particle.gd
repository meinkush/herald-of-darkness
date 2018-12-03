extends Particles2D

func _process(delta):
	if !emitting:
		queue_free()
