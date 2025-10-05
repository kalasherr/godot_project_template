extends BaseCandle

class_name BlueCandle

func get_key():
	return "blue"
	
func on_fire():
	if !lighted:
		await light_up()
		G.GS.get_light(1, self)
		var arr = []
		for i in range(0,8):
			if G.CS.get_candle(i):
				if !G.CS.get_candle(i).lighted:
					arr.append(i)
		if !arr == []:
			G.GS.add_action(G.CS.get_candle(arr.pick_random()), "on_fire")
		await jump()
	return
