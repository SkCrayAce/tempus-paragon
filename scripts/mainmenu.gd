extends Node

@onready var texture_rect = %TextureRect
const Slums0 = preload("res://scenes/areas/slums0.tscn")

var breakloop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioPlayer.stop()
	AudioPlayer.stream = null
	main_menu_play_anim()
	#TransitionScreen.fade_out_finished.connect(scene_transition)
	#TransitionScreen.fade_out_finished.connect(get_tree().change_scene_to_packed.bind(Slums0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $MainMenuMusic.playing == false:
		$MainMenuMusic.playing = true

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
