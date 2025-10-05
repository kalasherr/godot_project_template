extends Camera2D
@onready var def_fire_scale =get_node("BigFire").scale
var time = 0
var needed_time = 0.5
var texture = 1
var timer
var button
func _ready():
	G.C = self
	G.connect("gs_ready", on_gs_ready)
	position += Vector2(0,-100)
	
func check_tooltips():
	for node in G.GS.get_children():
		if node is Tooltip:
			return true
	return false

func _process(delta):
	if G.GS:
		if button:
			
			if G.GS.get_node("Button").is_hovered() and timer == null and !check_tooltips():
				timer = Timer.new()
				timer.autostart = false
				add_child(timer)
				timer.start(0.5)
				timer.connect("timeout", show_tooltip)
			if !G.GS.get_node("Button").is_hovered() and timer or Input.is_action_pressed("lmb"):
				if timer:
					timer.queue_free()
				for node in G.GS.get_children():
					if node is Tooltip:
						T.tween(node, "modulate", Color(1,1,1,0), 0.5)
				await get_tree().create_timer(0.5).timeout
				for node in G.GS.get_children():
					if node is Tooltip:
						node.queue_free()
		else:
			for child in G.GS.get_children():
				if child.name == "Button":
					button = child
	time += get_process_delta_time()
	if time > needed_time:
		time = 0
		if texture == 1:
			texture = 2
			get_node("BigFire").texture = load("res://sprites/small_fire2.png")
		else:
			texture = 1
			get_node("BigFire").texture = load("res://sprites/small_fire.png")

func update(amount):
	T.tween(get_node("BigFire"), "rotation", randf_range(deg_to_rad(-10),deg_to_rad(10)), 0.1)
	await T.tween(get_node("BigFire"), "scale", def_fire_scale * 1.2, 0.1)
	
	get_node("Label").text = str(amount) + "/" + str(G.GS.needed_light[G.GS.current_round])
	T.tween(get_node("BigFire"), "rotation", 0, 0.1)
	await T.tween(get_node("BigFire"), "scale", def_fire_scale * 1, 0.1)

func on_gs_ready():
	update(0)

func show_tooltip():
	timer.disconnect("timeout", show_tooltip)
	var tooltip = load("res://scenes/utils/candle_tooltip.tscn").instantiate()
	tooltip.modulate[3] = 0
	T.tween(tooltip, "modulate", Color(1,1,1,1), 0.2)
	G.GS.add_child(tooltip)
	tooltip.get_node("Label").text = "Light up all candles from left to right.\nCollect required score to proceed to next stage"
	tooltip.global_position = get_global_mouse_position() + Vector2(0,100)
