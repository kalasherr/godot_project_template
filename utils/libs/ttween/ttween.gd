extends Node

class_name TTween

var default_f = func(x):
	return x

func interpolate(a, b, t):
	return a + (b - a) * t

func tween(node, property, target, duration, f = default_f	):
	duration = duration / G.animation_time_scale
	if property is Array:
		var start = []
		for i in range(0,property.size()):
			start.append(node.get(property[i]))
		var start_time = Time.get_ticks_msec() / 1000.0
		var end_time = start_time + duration
		while Time.get_ticks_msec() / 1000.0 - end_time < 0:
			for i in range(0,property.size()):
				var ratio = (Time.get_ticks_msec() / 1000.0 - start_time) / duration
				var value = interpolate(start[i], target[i], f.call(ratio))
				if node:
					node.set(property[i], value)
				else:
					break
			await T.tick
		for i in range(0,property.size()):
			if node:
				node.set(property[i], target[i])
			else:
				break
		queue_free()
		return
	else:
		var start = node.get(property)
		var start_time = Time.get_ticks_msec() / 1000.0
		var end_time = start_time + duration
		while Time.get_ticks_msec() / 1000.0 - end_time < 0:
			var ratio = (Time.get_ticks_msec() / 1000.0 - start_time) / duration
			var value = interpolate(start, target, f.call(ratio))
			if node:
				node.set(property, value)
			else:
				break
			await T.tick
		if node:
			node.set(property, target)
		queue_free()
		return

func animate(node, property, target, duration, f = default_f):
	duration = duration / G.animation_time_scale
	if node is Node:
		var start_time = Time.get_ticks_msec() / 1000.0
		var end_time = start_time + duration
		while Time.get_ticks_msec() / 1000.0 - end_time < 0:
			var ratio = (Time.get_ticks_msec() / 1000.0 - start_time) / duration
			var value = f.call(ratio)
			if node:
				node.set(property, value)
			else:
				break
			await T.tick
		if node:
			node.set(property, target)
		queue_free()
		return

# Broken due to non-referencable types (Vector2, int, string etc.)	
func set_property(object, property, value):
	if object is Vector2:
		if property == "x":
			object.x = value
		if property == "y":
			object.y = value
	if object is Vector3:
		if property == "x":
			object.x = value
		if property == "y":
			object.y = value
		if property == "z":
			object.z = value
	if object is Color:
		if property == "r":
			object.r = value
		if property == "g":
			object.g = value
		if property == "b":
			object.b = value
		if property == "a":
			object.a = value

func get_property(object, property):
	if object is Vector2:
		if property == "x":
			return object.x
		if property == "y":
			return object.y
	if object is Vector3:
		if property == "x":
			return object.x
		if property == "y":
			return object.y
		if property == "z":
			return object.z
	if object is Color:
		if property == "r":
			return object.r
		if property == "g":
			return object.g
		if property == "b":
			return object.b
		if property == "a":
			return object.a
