extends Node

signal tick

func _process(delta):
	emit_signal("tick")

var default_f = func(x):
	return x
	
func interpolate(a, b, t):
	return a + (b - a) * t

func tween(node, property, target, duration, f = default_f):
	var ttween = TTween.new()
	await ttween.tween(node, property, target, duration, f)
	return

func animate(node, property, target, duration, f = default_f):
	var ttween = TTween.new()
	await ttween.animate(node, property, target, duration, f)
	return
