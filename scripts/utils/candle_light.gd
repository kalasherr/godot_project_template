extends PointLight2D

class_name CandleLight

var time = 0
var needed_time = 0.5

func _process(delta):
	time += get_process_delta_time()
	if visible:
		if time > needed_time:
			time = 0
			var particle = load("res://scenes/particle.tscn").instantiate()
			var rand = randf_range(0,1)
			particle.scale = randf_range(0.01, 0.05) * Vector2(1,1)
			particle.modulate = Color(237.0/256, 59.0/256, 0, 1) * rand + (1 - rand) * Color(255.0/256, 211.0/256, 17.0/256, 1)
			particle.z_index -= 1
			G.GS.add_child(particle)
			particle.global_position = self.global_position
			T.tween(particle, "modulate", Color(particle.modulate[0], particle.modulate[1], particle.modulate[2], 0), 3)
			await T.tween(particle, "global_position", particle.global_position + Vector2(80,0).rotated(randf_range(0,2 * PI)), 3)
			particle.queue_free()
