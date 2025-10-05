extends Node2D

class_name Tooltip

func _ready():
	z_index = 50

func _process(delta):
	if get_node("Label").text != "":
		get_node("Sprite").scale.y = get_node("Label").get_visible_line_count() * 0.1
