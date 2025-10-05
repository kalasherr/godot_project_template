extends Node2D

class_name BaseCandle

var button
var sprite
var light
var prev_position = global_position
var prev_parent
var offset = Vector2(0, -380)
var default_scale = 0.3
var jump_height = 50
var bound_place
var lighted = false
var timer
var avg_color

func _ready():
	preready()
	self.scale = Vector2(1,1) * default_scale
	set_sprite()
	set_button()
	add_light()
	postready()

func _process(delta):
	if self.global_position.y > -100:
		z_index = 3
	else:
		z_index = 0
		
	if is_hovered() and timer == null and !check_tooltips():
		timer = Timer.new()
		timer.autostart = false
		add_child(timer)
		timer.start(0.5)
		timer.connect("timeout", show_tooltip)
		
	if !is_hovered() and timer or Input.is_action_pressed("lmb"):
		if timer:
			timer.queue_free()
		for node in G.GS.get_children():
			if node is Tooltip:
				T.tween(node, "modulate", Color(1,1,1,0), 0.5)
		await get_tree().create_timer(0.5).timeout
		for node in G.GS.get_children():
			if node is Tooltip:
				node.queue_free()

func check_tooltips():
	for node in G.GS.get_children():
		if node is Tooltip:
			return true
	return false

func show_tooltip():
	timer.disconnect("timeout", show_tooltip)
	var tooltip = load("res://scenes/utils/candle_tooltip.tscn").instantiate()
	tooltip.modulate[3] = 0
	T.tween(tooltip, "modulate", Color(1,1,1,1), 0.2)
	G.GS.add_child(tooltip)
	tooltip.get_node("Label").text = G.candles_data[get_key()]
	tooltip.global_position = get_global_mouse_position() - Vector2(0,100)

func preready():
	pass
	
func postready():
	pass

func set_sprite():
	sprite = Sprite2D.new()
	sprite.texture = load("res://sprites/" + get_key() + "_candle.png")
	var img = sprite.texture.get_image()
	var pixel_count = 0
	var total_r = 0
	var total_g = 0
	var total_b = 0
	for x in img.get_width():
		for y in img.get_height():
			var color: Color = img.get_pixel(x, y)
			if color.a != 0:
				total_r += color.r
				total_g += color.g
				total_b += color.b
				pixel_count += 1
	if pixel_count > 0:
		avg_color =  Color(total_r / pixel_count, total_g / pixel_count, total_b / pixel_count)
	add_child(sprite)
	var fire = Sprite2D.new()
	fire.name = "Fire"
	fire.texture = load("res://sprites/fire.png")
	fire.visible = false
	sprite.add_child(fire)

func get_key():
	return "default"
	
func set_button():
	button = CandleHitbox.new()
	button.texture_click_mask = load("res://sprites/white_candle_bitmap.png")
	add_child(button)

func is_hovered():
	return button.is_hovered() and !button.disabled

func drop():
	light_down()
	sprite.texture = load("res://sprites/" + get_key() + "_candle.png")
	var f = func(x):
		return 1 - (x - 1) ** 2
	T.tween(self, "rotation", 0, 0.2, f)
	T.tween(self, "scale", Vector2(1,1) * default_scale, 0.2, f)
	if abs(get_global_mouse_position().y - G.I.global_position.y) < 100:
		reparent(G.I)
		return
	
	var valid = G.CS.get_valid_position(self)
	if valid:
		G.CS.clear_tutor()
		G.CS.disable_all()
		bound_place = G.CS.get_nearest_place(self.global_position + offset * default_scale)
		bound_place.bound_candle = self
		await T.tween(self, "global_position", valid, 0.2, f)
		for i in range(0,50):
			add_particle_on_drop()
		G.CS.enable_all()
	else:
		G.CS.disable_all()
		if prev_parent is Inventory:
			reparent(prev_parent)
			await T.tween(self, "global_position", prev_position, 0.2, f)
			G.CS.enable_all()
		else:
			reparent(prev_parent)
			bound_place = G.CS.get_nearest_place(prev_position + offset * default_scale)
			bound_place.bound_candle = self
			await T.tween(self, "global_position", prev_position, 0.2, f)
			G.CS.enable_all()
	light.shadow_enabled = true
		
func add_particle_on_drop():
	var particle = load("res://scenes/particle.tscn").instantiate()
	var rand = randf_range(0,1)
	particle.position.y = randf_range(-100,100)
	particle.scale = randf_range(0.01, 0.05) * Vector2(1,1)
	particle.modulate = avg_color
	particle.z_index -= 1
	G.GS.add_child(particle)
	particle.global_position = self.global_position
	particle.global_position.y += randf_range(-100,100)
	T.tween(particle, "modulate", Color(particle.modulate[0], particle.modulate[1], particle.modulate[2], 0), 0.5)
	await T.tween(particle, "global_position", particle.global_position + Vector2(80,0).rotated(randf_range(0,2 * PI)), 0.5)
	particle.queue_free()

func disable():
	button.disabled = true

func enable():
	button.disabled = false

func on_fire():
	light_up()
	return

func on_extinguish():
	light_down()
	return

func jump():
	G.play(get_key())
	sprite.texture = load("res://sprites/" + get_key() + "_candle_activated.png")
	var old_pos = global_position
	var f = func(x):
		return Vector2(old_pos.x,- (1 - (2 * x - 1) ** 2) * jump_height + old_pos.y)
	await T.animate(self, "position", self.position, 0.3, f)
	sprite.texture = load("res://sprites/" + get_key() + "_candle.png")
	return

func light_up():
	lighted = true
	G.CS.emit_signal("candle_fired")
	sprite.get_node("Fire").visible = true
	light.visible = true
	await get_tree().create_timer(0.2).timeout
	return

func light_down():
	lighted = false
	G.CS.emit_signal("candle_extinguished")
	sprite.get_node("Fire").visible = false
	light.visible = false
	await get_tree().create_timer(0.2).timeout
	return

func send_fire():
	var fire = Sprite2D.new()
	fire.texture = load("res://sprites/small_fire.png")
	fire.scale = Vector2(0.1,0.1)
	fire.global_position += Vector2(0,-300)
	add_child(fire)
	T.tween(fire, "scale", Vector2(0.5,0.5), 0.5)
	await T.tween(fire, "global_position", G.GS.fire_collection_position , 0.5)
	fire.queue_free()

func add_light():
	light = load("res://scenes/utils/candle_light.tscn").instantiate()
	light.scale = Vector2(300,300)
	light.position = -Vector2(40,300)
	light.visible = false
	light.shadow_enabled = true
	add_child(light)

func invert():
	if lighted:
		on_extinguish()
	else:
		on_fire()
