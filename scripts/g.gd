extends Node2D

class_name GScene

signal gs_ready

var animation_time_scale = 1

var GS
var CS
var F
var C
var I

var pitch = 1

var candles_data = {
	"black" :"On light up:\n Extinguish nearby candles. Add 1 light to score",
	"green" :"On light up:\n Add 1 to score for each nearby lighted candle (include itself)",
	"orange" :"On extinguish:\n Add 1 to score and light up itself",
	"pink" :"On light up:\n Light up nearby candles. Add 1 to score\n On extinguish:\n Extinguish nearby candles. Add 1 to score.\n Max: 3 actions",
	"white" :"On light up:\n Add 1 light to score and extinguish itself",
	"yellow" :"Extinguish all candles every 6 light ups on candelabra\nMax: 2 actions",
	"red" : "On fire: invert nearby candles",
	"blue" : "On fire: Light up random candle.\nAdd 1 light to score"
}
var sound_data = {
	"black" : "a5",
	"green" : "d5",
	"orange": "b5",
	"pink"  : "c6",
	"white" : "c5",
	"yellow": "f5",
	"red" : "b5",
	"blue": "rand"
}

func rand():
	return ["a5","d5","b5","c6","c5","f5"].pick_random()
	
var preview_shown = false

func _ready():
	pass
	

func play(sound):
	
	if sound != "ge" and sound != "be" and G.GS.count_locked:
		pitch += 0.01
	if len(sound) != 2:
		sound = sound_data[sound]
	if sound == "rand":
		sound = rand()
	if sound:
		var audio = AudioStreamPlayer.new()
		get_node("Audio").add_child(audio)
		audio.pitch_scale = pitch
		audio.stream = load("res://sounds/" + sound + ".mp3")
		audio.volume_db -= 10
		audio.play()
