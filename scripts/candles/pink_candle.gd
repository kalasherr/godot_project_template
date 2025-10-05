extends BaseCandle

class_name PinkCandle

var times = 0

func postready():
	G.GS.connect("count_start", reset)

func reset():
	times = 0

func get_key():
	return "pink"
	
func on_fire():
	if !lighted:
		await light_up()
		if times < 3:
			times += 1
			G.GS.get_light(1, self)
			if G.CS.get_candle(bound_place.pos - 1):
				G.GS.add_action(G.CS.get_candle(bound_place.pos - 1), "on_fire")
			if G.CS.get_candle(bound_place.pos + 1):
				G.GS.add_action(G.CS.get_candle(bound_place.pos + 1), "on_fire")
			await jump()	
	return

func on_extinguish():
	if lighted:
		await light_down()
		if times < 3:
			times += 1
			G.GS.get_light(1, self)
			if G.CS.get_candle(bound_place.pos - 1):
				G.GS.add_action(G.CS.get_candle(bound_place.pos - 1), "on_extinguish")
			if G.CS.get_candle(bound_place.pos + 1):
				G.GS.add_action(G.CS.get_candle(bound_place.pos + 1), "on_extinguish")
			await jump()
	return
