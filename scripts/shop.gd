extends Node2D

class_name Shop

func init(assortment):
	set_sprite()
	z_index = 5
	self.position.y = -1000
	for candle in assortment:
		var slot = ShopSlot.new()
		slot.bound_type = candle
		slot.position = Vector2((assortment.find(candle) - (assortment.size() - 1.0) / 2) * 100, 0)
		slot.scale = slot.init_scale
		slot.init()
		add_child(slot)
	var f = func(x):
		return 1 - ((x - 1)** 2)
	T.tween(self, "position", Vector2(0,-200), 1, f)

func end():
	var f = func(x):
		return x ** 2
	await T.tween(self, "position", Vector2(position.x, position.y - 1000), 1, f)
	queue_free()
	return

func set_sprite():
	var label = Label.new()
	var sprite = Sprite2D.new()
	sprite.light_mask = 0
	sprite.texture = load("res://sprites/inventory.png")
	sprite.scale = Vector2(1,1)
	sprite.z_index -= 1
	add_child(sprite)
	var texture_size = sprite.texture.get_size()
	label.size = Vector2(texture_size.x, texture_size.y / 2)
	label.position = Vector2( - texture_size.x / 2, - texture_size.y / 2) + Vector2(0,- 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = "Pick 2. Choose wisely"
	label.add_theme_font_size_override("font_size", 30)
	add_child(label)
