extends Node2D

class_name CandlePlace

var sprite
var pos
var bound_candle

func _ready():
	z_index += 1
	set_sprite()

func set_sprite():
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = load("res://sprites/candle_place.png")
	add_child(sprite)
	var subsprite = Sprite2D.new()
	subsprite.name = "Bottom"
	subsprite.texture = load("res://sprites/place_bottom.png")
	subsprite.position.y += 600
	add_child(subsprite)