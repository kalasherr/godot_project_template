extends BaseCandle

class_name WhiteCandle

func get_key():
	return "white"

func on_fire():
	if !lighted:
		light_up()
		G.GS.get_light(1, self)
		await jump()
		light_down()
	return
