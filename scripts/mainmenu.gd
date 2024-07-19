extends Node

@onready var texture_rect = %TextureRect
var breakloop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu_play_anim()
	TransitionScreen.transition_finished.connect(scene_transition)

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
			break

func _on_play_btn_pressed():
	breakloop = true
	TransitionScreen.transition_node.play("fade_out")


func _on_button_3_pressed():
	get_tree().quit()

func scene_transition():
	get_tree().change_scene_to_file("res://scenes/areas/slums0.tscn")
