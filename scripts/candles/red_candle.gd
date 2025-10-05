extends BaseCandle

class_name RedCandle

func get_key():
	return "red"
	
func on_fire():
	if !lighted:
		await light_up()
		if G.CS.get_candle(bound_place.pos - 1):
			G.GS.add_action(G.CS.get_candle(bound_place.pos - 1), "invert")
		if G.CS.get_candle(bound_place.pos + 1):
			G.GS.add_action(G.CS.get_candle(bound_place.pos + 1), "invert")
		await jump()	
	return
