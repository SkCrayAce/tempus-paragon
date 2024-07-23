extends AudioStreamPlayer

const battle_music = preload("res://audio/music/battle_music.wav")
const slums_battle_music = preload("res://audio/music/slums_battle.mp3")
const slums_music = preload("res://audio/music/slums.mp3")
const slums_bf_music = preload("res://audio/music/slums_boss_battle.mp3")
const city_music = preload("res://audio/music/overworld01_v02.wav")
#const underground_music = preload()


func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()


func play_battle_music():
	if global.slums_boss_battle:
		_play_music(slums_bf_music, -15.0)
	elif global.curr_area == "slums":
		_play_music(slums_battle_music, -15.0)
		
func play_music_level():
	if global.curr_area == "slums":
		_play_music(slums_music)
	elif global.curr_area == "city":
		_play_music(city_music)
	#elif global.curr_area == "underground"
		#_play_music(underground_music)

func _process(delta):
	if playing == false or get_tree().paused:
		playing = true
		
