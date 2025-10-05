extends BaseCandle

class_name GreenCandle

func get_key():
	return "green"
	
func on_fire():
	if !lighted:
		light_up()
		var amount = 1
		if G.CS.get_candle(bound_place.pos + 1):
			if G.CS.get_candle(bound_place.pos + 1).lighted:
				amount += 1
		if G.CS.get_candle(bound_place.pos - 1):
			if G.CS.get_candle(bound_place.pos - 1).lighted:
				amount += 1
		G.GS.get_light(amount, self)
		jump()
	return
