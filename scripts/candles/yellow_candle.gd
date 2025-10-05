extends BaseCandle

class_name YellowCandle

var counter = 0
var times_used = 0
func get_key():
	return "yellow"

func postready():
	G.CS.connect("candle_fired", give_light)
	G.CS.connect("count_start", reset)

func on_fire():
	if !lighted:
		light_up()
		G.GS.get_light(1, self)
		await jump()
	return

func give_light():
	if times_used != 2:
		times_used += 1
		if get_parent().get_parent() is CandleScene and !(get_parent() is Inventory):
			if counter == 6:
				counter = 0
				await jump()
				for i in range(0, G.CS.place_count):
					if G.CS.get_candle(i):
						if G.CS.get_candle(i) != self:
							G.GS.add_action(G.CS.get_candle(i), "on_extinguish")
			else:
				counter += 1

func reset():
	times_used = 0
	counter = 0