extends Node2D

class_name ShopSlot

var button
var sprite
var bound_type
var init_scale = Vector2(0.2,0.2)
var timer
var candle
var time = 0
var played = false
func init():
	set_sprite()

func set_sprite():
	candle = bound_type.new()
	sprite = Sprite2D.new()
	sprite.texture = load("res://sprites/" + candle.get_key() + "_candle.png")
	add_child(sprite)
	button = TextureButton.new()
	button.texture_click_mask = load("res://sprites/white_candle_bitmap.png")
	add_child(button)
	button.name = "Button"
	get_node("Button").position = - Vector2(150,500)
	button.connect("pressed", chosen)

func _process(delta):
	time += get_process_delta_time()
	if get_node("Button").is_hovered():
		scale = init_scale * Vector2(1.2,1.2)
		rotation = deg_to_rad(sin(time * 2) * 5)
		sprite.texture = load("res://sprites/" + candle.get_key() + "_candle_activated.png")
		if !played:
			played = true
			G.play(candle.get_key())
	else:
		rotation = deg_to_rad(sin(time * 2 + 1) * 2)
		scale = init_scale
		sprite.texture = load("res://sprites/" + candle.get_key() + "_candle.png")
		played = false
	if get_node("Button").is_hovered() and timer == null and !check_tooltips():
		timer = Timer.new()
		timer.autostart = false
		add_child(timer)
		timer.start(0.5)
		timer.connect("timeout", show_tooltip)
	if !get_node("Button").is_hovered() and timer or Input.is_action_pressed("lmb"):
		if timer:
			timer.queue_free()
		for node in G.GS.get_children():
			if node is Tooltip:
				T.tween(node, "modulate", Color(1,1,1,0), 0.5)
		await get_tree().create_timer(0.5).timeout
		for node in G.GS.get_children():
			if node is Tooltip:
				node.queue_free()

func show_tooltip():
	timer.disconnect("timeout", show_tooltip)
	var tooltip = load("res://scenes/utils/candle_tooltip.tscn").instantiate()
	tooltip.modulate[3] = 0
	T.tween(tooltip, "modulate", Color(1,1,1,1), 0.2)
	G.GS.add_child(tooltip)
	tooltip.get_node("Label").text = G.candles_data[candle.get_key()]
	tooltip.global_position = get_global_mouse_position() - Vector2(0,100)

func check_tooltips():
	for node in G.GS.get_children():
		if node is Tooltip:
			return true
	return false

func chosen():
	G.play(candle.get_key())
	button.disabled = true
	var places = []
	for place in G.CS.places.get_children():
		if place.bound_candle == null:
			places.append(place.pos)
	G.CS.add_candle(places.pick_random(), bound_type)
	G.GS.emit_signal("choice_button_pressed")
	var f = func(x):
		return x ** 2
	modulate = Color(0.8, 0.8, 0.8)
	await T.tween(self, "position", position + Vector2(0,-1000), 1, f)
	queue_free()
