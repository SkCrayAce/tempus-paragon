extends Node

@onready var texture_rect = %TextureRect
const Slums0 = preload("res://scenes/areas/slums0.tscn")
const MAIN_MENU_MUSIC = preload("res://audio/music/main_menu_music.mp3")

var breakloop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not AudioPlayer.stream == MAIN_MENU_MUSIC:
		AudioPlayer.stream = MAIN_MENU_MUSIC
		AudioPlayer.play()
	else:
		AudioPlayer.stream_paused = false
		
	main_menu_play_anim()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if $MainMenuMusic.playing == false:
		#$MainMenuMusic.playing = true

func main_menu_play_anim():
	while true:
		var tween = create_tween()
		tween.tween_property(texture_rect, "position", Vector2(texture_rect.position.x,texture_rect.position.y-10), 1).set_trans(Tween.TRANS_SINE)
		await tween.finished
		tween = create_tween()
		tween.tween_property(texture_rect, "position", Vector2(texture_rect.position.x,texture_rect.position.y+10), 1).set_trans(Tween.TRANS_SINE)
		await tween.finished
		if breakloop == true:
			tween.kill()
			break

func _on_play_btn_pressed():
	breakloop = true
	#get_tree().change_scene_to_packed(Slums0)
	#TransitionScreen.play_transition("fade_out")
	NavigationManager.start_game()


func _on_button_3_pressed():
	get_tree().quit()


func _on_options_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/options.tscn")
