extends Node2D

class_name CandleScene

var default_places_threshold = 120
var place_count = 8

@onready var candles = get_node("Candles")
@onready var places = get_node("Places")

signal candle_extinguished
signal candle_fired 

func _ready():
	G.CS = self
	await get_tree().process_frame
	add_places()
	add_candle(-1, WhiteCandle)

func get_candles(): 
	return get_children()

func clear_tutor():
	for sprite in get_children():
		if sprite is Sprite2D:
			sprite.queue_free()
			
func add_places():
	for i in range(0, place_count):
		var sprite = Sprite2D.new()
		sprite.scale = 0.3 * Vector2(1,1)
		sprite.texture = load("res://sprites/empty_candle.png")
		add_child(sprite)
		sprite.position.x = (i - (place_count / 2.0) + 0.5) * default_places_threshold + 5
		sprite.position.y = -130
		var place = load("res://scenes/utils/candle_place.tscn").instantiate()
		place.position.x = (i - (place_count / 2.0) + 0.5) * default_places_threshold
		place.scale = Vector2(1,1) * 0.3
		place.pos = i
		get_node("Places").add_child(place)
		

func add_candle(pos, candle_class):
	var candle = candle_class.new()
	if pos != -1:
		disable_all()
		candle.position.x = (pos - (place_count / 2.0) + 0.5) * default_places_threshold
		candle.position.y = -1000
		var target_y = candle.offset.y * candle.default_scale
		candle.bound_place = get_nearest_place(candle.global_position - Vector2(0, - candle.offset.y * candle.default_scale))
		candle.bound_place.bound_candle = candle
		candles.add_child(candle)
		var f = func(x):
			return 1 - (1 - x) ** 2
		await T.tween(candle, "position", Vector2(candle.position.x, target_y), 1, f)
		enable_all()
	else:
		G.I.add_child(candle)
		
func get_valid_position(candle):
	for place in places.get_children():
		if !place.bound_candle and (place.global_position - candle.global_position - Vector2(0, place.get_node("Sprite").texture.get_size().y / 2)).length() < 50:
			return place.global_position + candle.offset * candle.default_scale
	return null

func disable_all():
	for candle in candles.get_children():
		if candle is BaseCandle:
			candle.disable()
	for candle in G.I.get_children():
		if candle is BaseCandle:
			candle.disable()

func enable_all():
	for candle in candles.get_children():
		if candle is BaseCandle:
			candle.enable()
	for candle in G.I.get_children():
		if candle is BaseCandle:
			candle.enable()

func get_nearest_place(pos):
	var min = 100000
	var nearest_place = null
	for place in places.get_children():
		if (place.global_position - pos).length() < min:
			min = (place.global_position - pos).length()
			nearest_place = place
	return nearest_place
	
func get_candle(pos):
	for place in places.get_children():
		if place.pos == pos:
			return place.bound_candle
