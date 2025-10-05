extends TextureButton

class_name CandleHitbox

func _ready():
	self.position = - size / 2
	connect("pressed", _on_pressed)

func _on_pressed():
	pass
