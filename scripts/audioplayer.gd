extends AudioStreamPlayer

const slums_music = preload("res://audio/music/overworld-slums01_v02.wav")
const city_music = preload("res://audio/music/overworld01_v02.wav")
#const underground_music = preload()

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_music_level():
	if global.curr_area == "slums":
		_play_music(slums_music)
	elif global.curr_area == "city":
		_play_music(city_music)
	#elif global.curr_area == "underground"
		#_play_music(underground_music)
