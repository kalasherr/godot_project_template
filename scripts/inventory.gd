extends Node2D

class_name Inventory

var particle_spawn_time = 0.2
var time = 0
var default_color
func _ready():
	G.I = self
	z_index = 3
	default_color = get_node("Light").color
	position.y += 50
	
func _process(delta):
	var mostleft = Vector2(-(get_children().size()) * 20,0)
	var mostright = Vector2(get_children().size() * 20,0)
	var children = []
	for child in get_children():
		if child is BaseCandle:
			children.append(child)
	var range = (mostright - mostleft) / (children.size() + 1)
	for i in range(0, children.size()):
		var child = children[i]
		child.position = (1 - get_process_delta_time() * 5) * child.position + 5 * get_process_delta_time() * ((children.find(child) + 0.5 - float(children.size()) / 2) * range)
	if time < particle_spawn_time:
		time += get_process_delta_time()
	else:
		time = 0
		var particle = load("res://scenes/particle.tscn").instantiate()
		G.GS.add_child(particle)
		var rand = randf_range(0,1)
		particle.scale = randf_range(0.01, 0.05) * Vector2(1,1)
		particle.modulate = Color(237.0/256, 59.0/256, 0, 1) * rand + (1 - rand) * Color(255.0/256, 211.0/256, 17.0/256, 1)
		particle.z_index = 4
		particle.global_position = self.global_position + Vector2(500, 0) * randf_range(-1,1) + Vector2(0, 50)
		T.tween(particle, "modulate", Color(particle.modulate[0], particle.modulate[1], particle.modulate[2], 0), 5)
		await T.tween(particle, "global_position", particle.global_position + Vector2(50 * randf_range(-1,1),-100), 5)
		particle.queue_free()
		
