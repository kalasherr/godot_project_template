extends Node2D

class_name GameScene

var needed_light = [1,3,7,10,15,20]
var current_round = 0
var light_count = 0
var counting = false
var action_stack = []
var rect1
var rect2
var rect1_pos
var rect2_pos
var time = 0
var pointer
var win = false
var blinds_opened = false
var started = false
@onready var fire_collection_position = get_node("Camera/BigFire").global_position
var count_locked = false
signal count_start
signal choice_button_pressed
signal accept
func _ready():
	G.play("ge")
	var rect = ColorRect.new()
	rect.size = Vector2(1,1) * 2000
	rect.color = Color(0,0,0,1)
	rect.position = -1000 * Vector2(1,1)
	rect.z_index = 103
	rect1 = Sprite2D.new()
	rect2 = Sprite2D.new()
	rect1.scale = Vector2(1,1) * 1.1
	rect2.scale = Vector2(1,1) * 1.1
	rect1.z_index = 100
	rect2.z_index = 101
	rect1.centered = false
	rect2.centered = false
	rect1.texture = load("res://sprites/bling.png")
	rect2.texture = load("res://sprites/bling.png")
	rect1.position.x = 0
	rect2.position.x = -950
	rect1.position.y = -550
	rect2.position.y = -600
	rect1_pos = rect1.position
	rect2_pos = rect2.position
	rect1.light_mask = 0
	rect2.light_mask = 0
	add_child(rect)
	add_child(rect1)
	add_child(rect2)
	G.GS = self
	G.emit_signal("gs_ready")
	var f = func(x):
		return (((x * 3.0 - 1.0) ** 2.0) - 1) / 3
	await T.tween(rect, "modulate", Color(0,0,0,0), 1)
	if !G.preview_shown:
		G.preview_shown = true
		await show_preview()
	blinds_opened = true
	T.tween(rect1, "rotation", 0, 1)
	G.play("st")
	T.tween(rect2, "rotation", 0, 1)
	T.tween(rect1, "position", Vector2(1000, -500), 1, f)
	await T.tween(rect2, "position", Vector2(-2000, -500), 1, f)
	rect.queue_free()
	started = true

func show_preview():
	var label = Label.new()
	label.custom_minimum_size = Vector2(500,500)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 60)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.text = "Game by Kalasherr (not Tinkerer)"
	label.position = - label.custom_minimum_size / 2 + Vector2(0,-150)
	add_child(label)
	label.z_index = 102
	label.light_mask = 0
	await get_tree().create_timer(3).timeout
	label.queue_free()

	return
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("accept")
	time += get_process_delta_time()
	drag_n_drop_check()
	if Input.is_action_just_pressed("ui_accept") and !count_locked and started:
		start_count()
	if Input.is_action_just_pressed("ui_cancel"):
		restart()
	if !blinds_opened:
		var sinus = sin(time * 5) * 5
		rect1.position.x = rect1_pos.x + sinus
		rect2.position.x = rect2_pos.x - sinus
		rect1.rotation = - deg_to_rad(sinus / 6) * 0.7
		rect2.rotation = deg_to_rad(sinus / 6) * 0.7

func drag_n_drop_check():
	if Input.is_action_just_pressed("lmb"):
		for candle in G.CS.candles.get_children():
			if candle is BaseCandle:
				if candle.is_hovered():
					G.pitch = 1
					G.play(candle.get_key())
					if candle.bound_place:
						candle.bound_place.bound_candle = null
					candle.bound_place = null
					candle.sprite.texture = load("res://sprites/" +candle.get_key() + "_candle_activated.png")
					candle.prev_position = candle.global_position
					candle.prev_parent = candle.get_parent()
					candle.light_up()
					candle.reparent(G.F)
					break
		for candle in G.I.get_children():
			if candle is BaseCandle:
				if candle.is_hovered():
					G.pitch = 1
					G.play(candle.get_key())
					candle.bound_place = null
					candle.prev_position = candle.global_position
					candle.sprite.texture = load("res://sprites/" +candle.get_key() + "_candle_activated.png")
					candle.prev_parent = candle.get_parent()
					candle.light_up()
					candle.reparent(G.F)
					break
	if !Input.is_action_pressed("lmb"):
		if G.F.get_children() == []:
			pass
		else:
			var candle = G.F.get_child(0)
			if candle is BaseCandle:
				candle.reparent(G.CS.candles)
				candle.drop()
					
func start_count():
	var found = false
	for i in range(0,8):
		if G.CS.get_candle(i):
			found = true
	if !found:
		var previous = G.I.get_node("Light").color
		T.tween(G.I.get_node("Light"), "color", Color(1,0,0,1), 0.1)
		G.play("cn")
		await get_tree().create_timer(0.15).timeout
		G.I.get_node("Light").color = G.I.default_color
		return
	count_locked = true
	var f = func(x):
		return x ** 2
	G.play("co")
	T.tween(G.I.get_node("Light"), "energy", 0, 0.2)
	await get_tree().create_timer(1).timeout
	pointer = Sprite2D.new() 	
	pointer.texture = load("res://sprites/pointer.png")
	pointer.z_index = 5
	pointer.light_mask = 0
	pointer.position.x = -500
	pointer.position.y = 50
	G.CS.add_child(pointer)
	emit_signal("count_start")
	if !counting:
		counting = true
		G.CS.disable_all()
		for i in range(0, G.CS.place_count):
			if G.CS.get_candle(G.CS.place_count - i - 1):
				add_action(G.CS.get_candle(G.CS.place_count - i - 1), "on_fire")
		if action_stack != []:
			
			await call_stack()
		await get_tree().create_timer(1).timeout
		counting = false
		for candle in G.CS.candles.get_children():
			if candle.lighted:
				get_light(1, candle)
				candle.light_down()
		if light_count >= needed_light[current_round]:
			G.pitch = 1
			G.play("ge")
		await get_tree().create_timer(0.5).timeout
		for candle in G.CS.candles.get_children():
			candle.reparent(G.I)
			candle.bound_place = null
		for place in G.CS.places.get_children():
			place.bound_candle = null
		G.CS.enable_all()
	T.tween(pointer, "modulate", Color(0,0,0,0), 0.3)
	pointer.queue_free()
	count_locked = false
	if light_count >= needed_light[current_round]:
		if needed_light.size() - 1 == current_round:
			end_game()
		else:
			await next_stage()
			light_count = 0
			G.C.update(0)
			G.play("co")
			T.tween(G.I.get_node("Light"), "energy", 2, 0.2)
			return
	else:
		G.pitch = 1
		G.play("be")
		restart()

func end_game():
	win = true
	restart()
	
func get_light(amount, sender = null):
	light_count += amount
	if sender:
		sender.send_fire()
	G.C.update(light_count)

func call_stack():
	var f = func(x):
		return x ** 2
	await T.tween(pointer, "global_position", Vector2(action_stack[0][0].global_position.x, pointer.global_position.y), 0.1, f)
	var action = action_stack[0]
	print(action_stack)
	action_stack[0][0].call(action_stack[0][1])
	
	T.tween(G.CS.get_node("Light"), "global_position", Vector2(action_stack[0][0].global_position.x, G.CS.get_node("Light").global_position.y), 0.1, f)
	if G.CS.get_node("Light").energy == 0:
		await T.tween(G.CS.get_node("Light"), "energy", 3, 0.2)
# 	if (action_stack[0][1] == "on_fire" and !action_stack[0][0].lighted) or (action_stack[0][1] == "on_extinguish" and action_stack[0][0].lighted):
# 		await get_tree().create_timer(0.5).timeout
# 	else:
# 		await get_tree().create_timer(0.1).timeout
	action_stack.pop_at(action_stack.find(action))
	await get_tree().create_timer(0.3).timeout
	if light_count >= 100:
		action_stack = []
	if action_stack != []:
		await call_stack()
	else:
		G.CS.get_node("Light").energy = 0
	return

func add_action(target, method):
	action_stack.push_front([target, method])
	print(action_stack[0][0].bound_place.pos, " ", action_stack[0][1])

func generate_choice(assortment):
	var choice = []
	for i in range(0,4):
		choice.append(assortment.pick_random())
		assortment.pop_at(assortment.find(choice[choice.size() - 1]))
	var shop = Shop.new()
	shop.init(choice)
	add_child(shop)
	
	
func next_stage():
	G.CS.disable_all()
	var assortment = [BlackCandle, GreenCandle, OrangeCandle, PinkCandle, WhiteCandle, YellowCandle, RedCandle, BlueCandle]
	generate_choice(assortment)
	await choice_button_pressed
	await choice_button_pressed
	for child in get_children():
		if child:
			if child is Shop:
				await child.end()
	current_round += 1
	G.CS.enable_all()

func restart():
	var f = func(x):
		return 1 - (x - 1) ** 2
	var goal1 = Vector2(-100,-500)
	var goal2 = Vector2(-900,-500)
	var rect = ColorRect.new()
	add_child(rect)
	rect.size = Vector2(1,1) * 2000
	rect.color = Color(0,0,0,0)
	rect.position = -1000 * Vector2(1,1)
	rect.z_index = 103
	T.tween(rect, "color", Color(0,0,0,1), 2.5, f)
	G.play("en")
	T.tween(rect1, "position", goal1, 2.5, f)
	T.tween(rect2, "position", goal2, 2.5, f)
	if win:
		var label = Label.new()
		label.text = "Thanks for playing.\nMade by kalasherr in 48 hours for Ludum Dare 58\nPress Space to restart"
		label.add_theme_font_size_override("font_size", 60)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size.x = 1000
		label.position = - label.size / 2 + Vector2(0, -200)
		label.modulate = Color(1,1,1,0)
		label.z_index = 110
		add_child(label)
		T.tween(label, "modulate", Color(1,1,1,1), 1)
		await accept
	else:
		await get_tree().create_timer(2.5).timeout
	self.queue_free()
	get_parent().add_child(load("res://scenes/game_scene.tscn").instantiate())


func _on_button_pressed():
	
	if !count_locked:
		start_count()
	
	await T.tween(get_node("Button"), "scale", Vector2(1.1,1.1), 0.05)
	T.tween(get_node("Button"), "scale", Vector2(1,1), 0.05)
