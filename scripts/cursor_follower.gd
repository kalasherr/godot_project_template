extends Node2D

class_name Follower

var time = 0
var needed_time = 0.1
var count_time = 0
func _ready():
	G.F = self
	
func _process(delta):
	time += get_process_delta_time()
	count_time += get_process_delta_time()
	self.position = G.GS.get_local_mouse_position()
	for child in get_children():
		child.rotation = deg_to_rad(sin(time * 5) * 100 * get_process_delta_time() + child.rotation * (1 - get_process_delta_time() ))
		child.scale = child.default_scale * Vector2(1,1) * (1 - get_process_delta_time() * 5) + child.default_scale * Vector2(1,1) * 3 * get_process_delta_time() * 5
		child.light.shadow_enabled = false
		if count_time < needed_time:
			pass
		else:
			count_time = 0
			var particle = load("res://scenes/particle.tscn").instantiate()
			var rand = randf_range(0,1)
			particle.position.y = randf_range(-100,100)
			particle.scale = randf_range(0.01, 0.05) * Vector2(1,1)
			particle.modulate = child.avg_color
			particle.z_index -= 1
			G.GS.add_child(particle)
			particle.global_position = self.global_position
			particle.global_position.y += randf_range(-100,100)
			T.tween(particle, "modulate", Color(particle.modulate[0], particle.modulate[1], particle.modulate[2], 0), 1)
			await T.tween(particle, "global_position", particle.global_position + Vector2(80,0).rotated(randf_range(0,2 * PI)), 1)
			particle.queue_free()
