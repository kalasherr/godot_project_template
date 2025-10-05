extends BaseCandle

class_name BlackCandle

func get_key():
	return "black"
	
func on_fire():
	if !lighted:
		await light_up()
		G.GS.get_light(1, self)
		
		if G.CS.get_candle(bound_place.pos - 1):
			G.GS.add_action(G.CS.get_candle(bound_place.pos - 1), "on_extinguish")
		if G.CS.get_candle(bound_place.pos + 1):
			G.GS.add_action(G.CS.get_candle(bound_place.pos + 1), "on_extinguish")
		await jump()
	return

func on_extinguish():
	if lighted:
		await light_down()
		G.GS.get_light(1, self)
	return
