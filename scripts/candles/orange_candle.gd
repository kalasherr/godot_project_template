extends BaseCandle

class_name OrangeCandle

func get_key():
	return "orange"

func postready():
	G.GS.connect("count_start", give_light)
	
# func on_fire():
# 	if !lighted:
# 		lighted = true
# 		G.GS.get_light(1)
# 		await jump()
# 		if G.CS.get_candle(bound_place.pos + 1):
# 			await G.CS.get_candle(bound_place.pos + 1).on_fire()
# 			await G.CS.get_candle(bound_place.pos + 1).on_extinguish()
# 	return

func on_extinguish():
	if lighted:
		await light_down()
		G.GS.get_light(1, self)
		await jump()
		await light_up()
	return

func give_light():
	if get_parent().get_parent() is CandleScene and !(get_parent() is Inventory):
		light_up()
